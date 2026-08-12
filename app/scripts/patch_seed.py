P = "app/src/lib/command-center.server.ts"
OLD = '''  { provider: "tiktok_ads", account_label: "TikTok Ads", kind: "platform", status: "waiting", url: "https://business-api.tiktok.com", note: "Authorization link sent" },
'''
s = open(P).read()
assert OLD in s, "anchor missing"
s = s.replace(OLD, NEW)
open(P, "w").write(s)
print("patched ok", s.count("TikTok Ads"))