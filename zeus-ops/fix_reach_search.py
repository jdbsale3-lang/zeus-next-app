#!/usr/bin/env python3
"""
fix_reach_search.py - make the BARE /reach/search path serve, without ever
creating a duplicate nginx location (which nginx rejects outright).

WHY PYTHON AND NOT SED:
The first version of this fix inserted a new

    location = /reach/search { return 301 /reach/search/; }

unconditionally. Testing on a simulated droplet showed that when the config
ALREADY contains an exact-match block (e.g. `location = /reach/search { deny all; }`
- the most likely cause of the 403), that produces TWO exact-match locations and
nginx refuses to start:

    nginx: [emerg] duplicate location "/reach/search"

So this version:
  1. finds the exact-match block for /reach/search
  2. if it exists -> rewrites it in place (replaces a `deny all;` inside it with the
     redirect, or collapses the whole block to the redirect)
  3. if it does not exist -> inserts the redirect straight after the server's brace
  4. verifies the result contains exactly ONE exact-match location before writing

The redirect is correct because the estate monitor's probe() uses urlopen, which
FOLLOWS redirects: 301 -> /reach/search/ -> 200, matching the route's want=200.

Usage:
  fix_reach_search.py <nginx-config-file> [--apply]
  without --apply it prints the change and writes nothing (dry run).
"""
import re
import sys
import pathlib

SERVER_HINT = "zeusaiintelligence.com"
REDIRECT = "location = /reach/search { return 301 /reach/search/; }"


def find_target_block(text, hint):
    """Return (start, end) of the server block whose server_name matches hint,
    else the first server block that mentions /reach/, else the first server block."""
    # crude but reliable for nginx: match innermost server { ... } blocks by brace scan
    blocks = []
    for m in re.finditer(r"(^|\n)\s*server\s*\{", text):
        start = m.end() - 1  # position of '{'
        depth = 0
        for i in range(start, len(text)):
            if text[i] == "{":
                depth += 1
            elif text[i] == "}":
                depth -= 1
                if depth == 0:
                    blocks.append((m.start(), i + 1))
                    break
    for b in blocks:
        seg = text[b[0]:b[1]]
        if hint in seg:
            return b
    for b in blocks:
        if "/reach/" in text[b[0]:b[1]]:
            return b
    return blocks[0] if blocks else None


def exact_match_spans(seg):
    """Find every `location = /reach/search ... { ... }` span inside seg."""
    spans = []
    for m in re.finditer(r"location\s*=\s*/reach/search\s*\{", seg):
        start = m.start()
        depth = 0
        for i in range(m.end() - 1, len(seg)):
            if seg[i] == "{":
                depth += 1
            elif seg[i] == "}":
                depth -= 1
                if depth == 0:
                    spans.append((start, i + 1))
                    break
    return spans


def count_exact_matches(text):
    return len(re.findall(r"location\s*=\s*/reach/search\s*\{", text))


def fix(text, hint=SERVER_HINT):
    if count_exact_matches(text) >= 1:
        # already pointed at the redirect? then there is nothing to do
        if re.search(r"location\s*=\s*/reach/search\s*\{\s*return\s+301\s+/reach/search/\s*;\s*\}", text):
            return text, "already redirects - no change needed"

    target = find_target_block(text, hint)
    if target is None:
        return text, "ERROR: no server block found"

    bstart, bend = target
    seg = text[bstart:bend]
    spans = exact_match_spans(seg)

    if spans:
        # rewrite in place - never add a second exact-match location
        s0, s1 = spans[-1]  # last one wins; extras are removed below
        inner = seg[s0:s1]
        if re.search(r"deny\s+all\s*;", inner):
            new_inner = re.sub(r"deny\s+all\s*;", "return 301 /reach/search/;", inner, count=1)
            action = "replaced 'deny all;' inside the existing exact-match location"
        else:
            new_inner = "location = /reach/search { return 301 /reach/search/; }"
            action = "collapsed the existing exact-match location to the redirect"
        seg_new = seg[:s0] + new_inner + seg[s1:]
        # if there were duplicates already, drop the extras (nginx would refuse to start)
        extra = 0
        while len(exact_match_spans(seg_new)) > 1:
            sp = exact_match_spans(seg_new)
            a, b = sp[0]
            seg_new = seg_new[:a] + seg_new[b:]
            extra += 1
        if extra:
            action += f"; removed {extra} pre-existing duplicate exact-match location(s)"
    else:
        # nothing exact-matching: insert right after the server brace
        brace = seg.index("{") + 1
        seg_new = seg[:brace] + "\n    " + REDIRECT + seg[brace:]
        action = "inserted the redirect after the server brace"

    out = text[:bstart] + seg_new + text[bend:]
    n = count_exact_matches(out)
    if n != 1:
        return out, f"ERROR: result has {n} exact-match locations (expected 1) - refusing"
    return out, action


# ─── self-test against every config shape we can meet ─────────────────────────
FIXTURES = {
    "A single-line exact-match deny": """
server {
    listen 443 ssl;
    server_name zeusaiintelligence.com;
    location = /reach/search { deny all; }
    location /reach/ { proxy_pass http://127.0.0.1:5000; }
}
""",
    "B multi-line exact-match deny": """
server {
    listen 443 ssl;
    server_name zeusaiintelligence.com;
    location = /reach/search {
        deny all;
    }
    location /reach/ { proxy_pass http://127.0.0.1:5000; }
}
""",
    "C no exact match, prefix proxy only": """
server {
    listen 443 ssl;
    server_name zeusaiintelligence.com;
    location /reach/ { proxy_pass http://127.0.0.1:5000; }
}
""",
    "D exact match with something else inside": """
server {
    server_name zeusaiintelligence.com;
    location = /reach/search { return 404; }
    location /reach/ { proxy_pass http://127.0.0.1:5000; }
}
""",
    "E already-created duplicates (broken config)": """
server {
    server_name zeusaiintelligence.com;
    location = /reach/search { deny all; }
    location = /reach/search { return 404; }
    location /reach/ { proxy_pass http://127.0.0.1:5000; }
}
""",
    "F two server blocks, target is the second": """
server {
    server_name other.example.com;
    location / { return 200; }
}
server {
    server_name zeusaiintelligence.com;
    location = /reach/search { deny all; }
    location /reach/ { proxy_pass http://127.0.0.1:5000; }
}
""",
}

if __name__ == "__main__":
    if len(sys.argv) == 1:
        print("=== self-test across every config shape ===")
        all_ok = True
        for name, cfg in FIXTURES.items():
            out, action = fix(cfg)
            n = count_exact_matches(out)
            has_301 = "return 301 /reach/search/;" in out
            ok = (n == 1) and has_301 and not action.startswith("ERROR")
            all_ok &= ok
            print(f"  [{'OK  ' if ok else 'FAIL'}] {name}")
            print(f"          action: {action}")
            print(f"          exact-match locations after: {n}   redirect present: {has_301}")
        print()
        print("RESULT:", "ALL SHAPES PASS" if all_ok else "SOME SHAPES FAILED")
        sys.exit(0 if all_ok else 1)

    path = pathlib.Path(sys.argv[1])
    apply = "--apply" in sys.argv
    text = path.read_text()
    out, action = fix(text)
    print(f"file   : {path}")
    print(f"action : {action}")
    if action.startswith("ERROR"):
        sys.exit(1)
    if out == text:
        print("no change needed")
        sys.exit(0)
    print("--- proposed result ---")
    print(out)
    if apply:
        path.with_suffix(path.suffix + ".bak").write_text(text)
        path.write_text(out)
        print(f"WRITTEN (backup at {path.name}.bak)")
    else:
        print("DRY RUN - nothing written. Add --apply to write.")
