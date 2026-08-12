import pathlib
P = pathlib.Path("/home/user/f56cf59a-677c-41c1-9dc3-1c248d8a5d5a/zeus-next-app-523e9c2b-5030-44aa-8c75-f6ed99fa9c80/app/src/layouts/command-center.tsx")
s = P.read_text()

# 1) Insert sphere (with caption) at the TOP of the ZEUS Live AI panel,
#    right after the panel header (Sparkle + "ZEUS Live AI" + voice toggle).
hdr = '                <button type="button" onClick={() => setVoiceOn((v) => !v)}\n                  className={cn("flex items-center gap-1.5 rounded-full border px-2 py-0.5 text-[9px] font-semibold tracking-widest",\n                    voiceOn ? "border-emerald-500/40 bg-emerald-500/10 text-emerald-300" : "border-slate-700 bg-slate-800/60 text-slate-500")}\n                  aria-pressed={voiceOn}>\n                  <Icon as={voiceOn ? Volume2 : VolumeX} size="sm" />\n                  {voiceOn ? "VOICE REPLIES ON" : "VOICE REPLIES OFF"}\n                </button>\n              </div>'

SPHERE = '''
              <div className="mb-3 flex flex-col items-center gap-1.5">
                <ZeusSphere listening={listening} busy={busy} onClick={toggleVoiceInput} />
                <p className="text-[10px] text-slate-500">
                  {listening
                    ? "● LISTENING — SPEAK YOUR COMMAND ●"
                    : voiceAvailable
                      ? nativeSpeech
                        ? "▲ TAP THE SPHERE AND TALK TO ZEUS ▲"
                        : "▲ TAP THE SPHERE AND RECORD — VOICE VIA RECORDING ▲"
                      : "Voice input isn't supported in this browser — use the chat box"}
                </p>
              </div>
            </div>
          </section>'''

# The panel ends: ...header div close, chat div, mic row, then panel close + section close.
panel_end = '                {busy ? (\n                  <Button variant="marketingPrimary" size="md" onClick={cancel}>Stop</Button>\n                ) : (\n                  <Button variant="marketingPrimary" size="md" onClick={() => ask()} disabled={!prompt.trim()}>Ask</Button>\n                )}\n              </div>\n            </div>\n          </section>'
NEW_PANEL_END = '                {busy ? (\n                  <Button variant="marketingPrimary" size="md" onClick={cancel}>Stop</Button>\n                ) : (\n                  <Button variant="marketingPrimary" size="md" onClick={() => ask()} disabled={!prompt.trim()}>Ask</Button>\n                )}\n              </div>\n            </div>\n            <div className="mb-3 flex flex-col items-center gap-1.5">\n              <ZeusSphere listening={listening} busy={busy} onClick={toggleVoiceInput} />\n              <p className="text-[10px] text-slate-500">\n                {listening\n                  ? "● LISTENING — SPEAK YOUR COMMAND ●"\n                  : voiceAvailable\n                    ? nativeSpeech\n                      ? "▲ TAP THE SPHERE AND TALK TO ZEUS ▲"\n                      : "▲ TAP THE SPHERE AND RECORD — VOICE VIA RECORDING ▲"\n                    : "Voice input isn\'t supported in this browser — use the chat box"}\n              </p>\n            </div>\n          </section>'
assert panel_end in s, "panel end anchor missing"
s = s.replace(panel_end, NEW_PANEL_END, 1)

# 2) Remove the old bottom sphere block entirely.
old_bottom = '''        {/* Bottom: Zeus sphere */}
        <div className="mt-8 flex flex-col items-center gap-2">
          <ZeusSphere listening={listening} busy={busy} onClick={toggleVoiceInput} />
          <p className="text-[10px] text-slate-500">
            {listening
              ? "● LISTENING — SPEAK YOUR COMMAND ●"
              : voiceAvailable
                ? nativeSpeech
                  ? "▲ TAP THE SPHERE AND TALK TO ZEUS ▲"
                  : "▲ TAP THE SPHERE AND RECORD — VOICE VIA RECORDING ▲"
                : "Voice input isn't supported in this browser — use the chat box"}
          </p>
        </div>
'''
if old_bottom in s:
    s = s.replace(old_bottom, "", 1)
    print("bottom sphere removed")
else:
    # tolerate slight whitespace variance
    start = s.find("        {/* Bottom: Zeus sphere */}")
    end = s.find("            : \"Voice input isn't supported in this browser — use the chat box\"}\n          </p>\n        </div>\n", start)
    if end != -1 and start != -1:
        s = s[:start] + s[end + len("            : \"Voice input isn't supported in this browser — use the chat box\"}\n          </p>\n        </div>\n"):]
        print("bottom sphere removed (v2)")
    else:
        print("!! bottom sphere NOT found — leaving as-is")

P.write_text(s)
print("done; ZeusSphere calls:", s.count("<ZeusSphere"))