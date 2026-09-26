# CORRECTION: the `/reach/search` 403 is INTENTIONAL — do not "fix" it

**Supersedes my earlier README-fix-reach-search.md, which was wrong. Do not apply that
nginx redirect.**

---

## What I got wrong

I diagnosed `/reach/search` → 403 as a misconfiguration and built a script to redirect
the bare path to `/reach/search/`. That was the **opposite** of correct.

Your own repository documents the 403 as a security control:

- `kali/SECURITY-REACH-EXPOSURE.md`
- `kali/SECURITY-FINDING-001-REACH-EXPOSURE.md` (reproduced 22 Sep 2026)

The finding: every `/reach/*` route answered **200 without a credential**, including the
**action routes** `/reach/search` and `/reach/gh`, which "consume the estate's **Exa
credits and GitHub API quota**; an attacker could burn quota". Remediation option #4 was
exactly "add an nginx location that blocks the *action* routes while keeping read-only
ones for the dashboard".

**So the 403 is the fix working.** My redirect would have pointed users straight back
into the closed route and made the exposure the documented behaviour.

## The hardening is INCOMPLETE — this is the real problem

The deny is an **exact match**, so it covers `/reach/search` but not `/reach/search/`.
Measured unauthenticated, 25 Sep 2026:

| Path | Bare | Trailing slash | Note |
|---|---|---|---|
| `/reach/search` | **403** | **200** | ACTION route - burns Exa quota |
| `/reach/gh` | **403** | **200** | ACTION route - burns GitHub quota |
| `/reach/skills` | 503 | **200** | |
| `/reach/self` | 200 | 200 | read-only, kept by design |
| `/reach/doctor` | 200 | 200 | read-only, kept by design |
| `/reach/monitor` | 200 | 200 | read-only, kept by design |
| `/reach/metrics` | 200 | 200 | read-only, kept by design |
| `/reach/platform` | 503 | 503 | upstream flapping |

**Captured live proof that the slash form serves paid results unauthenticated:**

```
GET https://zeusaiintelligence.com/reach/search/?q=zeus
-> {"ok": true, "source": "exa-mcp:web_search_exa",
    "output": "Title: Zeus\nURL: https://en.w..."}
```

That is a real Exa web search, executed and billed, for an anonymous caller. The bridge
was intermittently up during testing (some calls returned nginx 503), so the window is
intermittent — but it is live.

## The correct nginx fix: make the deny a PREFIX match

Replace the exact-match deny with a prefix deny (`^~` wins over other prefix locations):

```nginx
location ^~ /reach/search { deny all; }
location ^~ /reach/gh     { deny all; }
```

`^~` covers `/reach/search`, `/reach/search/`, and anything beneath it, in one directive.
Anything narrower than the prefix form leaves a slash-variant door open.

Keep `/reach/self`, `/reach/doctor`, `/reach/monitor`, `/reach/metrics` open **only** if
the Command Centre dashboard genuinely needs them unauthenticated — they disclose internal
host, skill inventory and channel status. Remediation #1 in your own finding (Cloudflare
Access on `/reach/*`, policy = your email) closes that class properly and keeps the
dashboard working while logged in.

## The CI gate: change the expectation, not the server

`estate-route-monitor.py` declares:

```python
("search", "https://zeusaiintelligence.com/reach/search?q=estate+monitor", True, 200),
```

That expectation is now backwards. With the hardening in place, **403 is the healthy
state**, so the route should assert it — which turns the monitor into a security
regression check:

```python
("search", "https://zeusaiintelligence.com/reach/search?q=estate+monitor", True, 403),
```

This works with the existing code: `probe()` already returns `ok: True` for
`e.code in (301, 302, 401, 403)`, and the post-processing compares status against `want`,
so `403 == 403` clears the deviation and the gate goes green.

That is the correct resolution of the failing `estate-route-monitor` job — **not** the
nginx redirect.

## My earlier fix_reach_search.py: keep it, retarget it

The Python fixer and its 15 unit tests still have value, but the directive it injects must
become the prefix form:

```python
REDIRECT = "location ^~ /reach/search { deny all; }"   # was: location = /reach/search { return 301 ... }
```

The invariant the tests enforce — never emit two locations for the same match, never
damage unrelated config — is exactly what you want for a security directive too.

## Succession of a correct verification

```bash
for p in /reach/search /reach/search/ /reach/gh /reach/gh/; do
  printf "%-20s %s\n" "$p" "$(curl -s -o /dev/null -w '%{http_code}' https://zeusaiintelligence.com$p)"
done
```

All four should be **403**. Any 200 on those paths means the quota-burning door is open.
