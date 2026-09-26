#!/usr/bin/env python3
"""
Unit tests for fix_reach_search.py.

Run:  python3 -m unittest test_fix_reach_search -v
  or: python3 test_fix_reach_search.py

The point of these tests is the failure that bit us in real life: an unconditional
insert produced TWO `location = /reach/search` blocks, and nginx refuses to start
with [emerg] duplicate location. Every test here asserts the invariant
"exactly one exact-match location survives", plus no collateral damage.
"""
import re
import unittest

from fix_reach_search import (
    REDIRECT,
    SERVER_HINT,
    count_exact_matches,
    exact_match_spans,
    find_target_block,
    fix,
)

ONE_LINE_DENY = """server {
    listen 443 ssl;
    server_name zeusaiintelligence.com;
    location = /reach/search { deny all; }
    location /reach/ { proxy_pass http://127.0.0.1:5000; }
}
"""

MULTI_LINE_DENY = """server {
    listen 443 ssl;
    server_name zeusaiintelligence.com;
    location = /reach/search {
        deny all;
    }
    location /reach/ { proxy_pass http://127.0.0.1:5000; }
}
"""

NO_EXACT_MATCH = """server {
    listen 443 ssl;
    server_name zeusaiintelligence.com;
    location /reach/ { proxy_pass http://127.0.0.1:5000; }
}
"""

OTHER_DIRECTIVE = """server {
    server_name zeusaiintelligence.com;
    location = /reach/search { return 404; }
    location /reach/ { proxy_pass http://127.0.0.1:5000; }
}
"""

PRE_EXISTING_DUPLICATES = """server {
    server_name zeusaiintelligence.com;
    location = /reach/search { deny all; }
    location = /reach/search { return 404; }
    location /reach/ { proxy_pass http://127.0.0.1:5000; }
}
"""

TWO_SERVER_BLOCKS = """server {
    server_name other.example.com;
    location / { return 200; }
}
server {
    server_name zeusaiintelligence.com;
    location = /reach/search { deny all; }
    location /reach/ { proxy_pass http://127.0.0.1:5000; }
}
"""

ALREADY_REDIRECTS = """server {
    server_name zeusaiintelligence.com;
    location = /reach/search { return 301 /reach/search/; }
    location /reach/ { proxy_pass http://127.0.0.1:5000; }
}
"""

NO_SERVER_BLOCK = """# nothing here
upstream backend { server 127.0.0.1:5000; }
"""


class TestInvariants(unittest.TestCase):
    """The invariant that matters: never leave more than one exact-match location."""

    def assert_sane(self, out, action):
        self.assertFalse(action.startswith("ERROR"), f"unexpected ERROR: {action}")
        self.assertEqual(
            count_exact_matches(out), 1,
            f"expected exactly 1 exact-match location, got {count_exact_matches(out)}",
        )
        self.assertIn("return 301 /reach/search/;", out, "redirect missing")

    def test_a_single_line_deny(self):
        out, action = fix(ONE_LINE_DENY)
        self.assert_sane(out, action)
        self.assertIn("replaced", action)
        self.assertNotIn("deny all;", out, "the deny should be gone")

    def test_b_multi_line_deny(self):
        out, action = fix(MULTI_LINE_DENY)
        self.assert_sane(out, action)
        self.assertNotIn("deny all;", out)

    def test_c_no_exact_match_inserts(self):
        out, action = fix(NO_EXACT_MATCH)
        self.assert_sane(out, action)
        self.assertIn("inserted", action)

    def test_d_other_directive_collapsed(self):
        out, action = fix(OTHER_DIRECTIVE)
        self.assert_sane(out, action)
        self.assertNotIn("return 404;", out, "the conflicting directive must be replaced")

    def test_e_pre_existing_duplicates_are_reduced_to_one(self):
        """The real-world failure: a broken config with two exact-match blocks."""
        self.assertEqual(count_exact_matches(PRE_EXISTING_DUPLICATES), 2)
        out, action = fix(PRE_EXISTING_DUPLICATES)
        self.assert_sane(out, action)
        self.assertIn("removed", action)

    def test_f_targets_the_right_server_block(self):
        out, action = fix(TWO_SERVER_BLOCKS)
        self.assert_sane(out, action)
        # the redirect must land in the zeusaiintelligence.com block, not the first one
        idx_redirect = out.index("location = /reach/search")
        idx_hint = out.index(SERVER_HINT)
        self.assertGreater(idx_redirect, idx_hint, "redirect landed in the wrong server block")

    def test_g_idempotent_running_twice_changes_nothing(self):
        once, _ = fix(ONE_LINE_DENY)
        twice, action = fix(once)
        self.assertEqual(once, twice, "second run must be a no-op")
        self.assertIn("already redirects", action)
        self.assertEqual(count_exact_matches(twice), 1)

    def test_h_already_redirecting_is_a_noop(self):
        out, action = fix(ALREADY_REDIRECTS)
        self.assertEqual(out, ALREADY_REDIRECTS)
        self.assertIn("already redirects", action)

    def test_i_no_server_block_errors_cleanly(self):
        out, action = fix(NO_SERVER_BLOCK)
        self.assertTrue(action.startswith("ERROR"), action)
        self.assertEqual(out, NO_SERVER_BLOCK, "must not modify a file it cannot fix")

    def test_j_no_collateral_damage(self):
        out, _ = fix(ONE_LINE_DENY)
        # everything unrelated must survive byte-for-byte
        for line in ("listen 443 ssl;", "server_name zeusaiintelligence.com;",
                     "location /reach/ { proxy_pass http://127.0.0.1:5000; }"):
            self.assertIn(line, out, f"lost unrelated line: {line}")


class TestHelpers(unittest.TestCase):
    def test_count_exact_matches(self):
        self.assertEqual(count_exact_matches(ONE_LINE_DENY), 1)
        self.assertEqual(count_exact_matches(PRE_EXISTING_DUPLICATES), 2)
        self.assertEqual(count_exact_matches(NO_EXACT_MATCH), 0)

    def test_count_ignores_prefix_locations(self):
        """`location /reach/search/` is a prefix match, not an exact match - do not count it."""
        text = "server {\n location /reach/search/ { deny all; }\n}\n"
        self.assertEqual(count_exact_matches(text), 0)

    def test_exact_match_spans_multiline(self):
        spans = exact_match_spans(MULTI_LINE_DENY)
        self.assertEqual(len(spans), 1)
        start, end = spans[0]
        block = MULTI_LINE_DENY[start:end]
        self.assertIn("deny all;", block)
        self.assertTrue(block.endswith("}"))

    def test_find_target_block_prefers_server_name(self):
        blk = find_target_block(TWO_SERVER_BLOCKS, SERVER_HINT)
        self.assertIsNotNone(blk)
        self.assertIn(SERVER_HINT, TWO_SERVER_BLOCKS[blk[0]:blk[1]])

    def test_redirect_constant_is_an_exact_match_redirect(self):
        self.assertTrue(REDIRECT.startswith("location = /reach/search"))
        self.assertIn("return 301 /reach/search/;", REDIRECT)
        # a single line - the fixer must never emit a stray brace
        self.assertEqual(REDIRECT.count("{"), 1)
        self.assertEqual(REDIRECT.count("}"), 1)


if __name__ == "__main__":
    unittest.main(verbosity=2)
