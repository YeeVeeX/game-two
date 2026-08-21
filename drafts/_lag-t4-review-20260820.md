# T4 vsync-release — fresh-eyes review receipt (2026-08-20, session 25)

Scrubbed read-only pi session (env -u PI_*), given: code diff, ticket doc,
contract §4, banked A/B logs. Verbatim output follows.

---

Review complete. I read every file, re-derived the mechanism from the installed gem source, and cross-checked the banked logs byte-for-byte. Note on independence: the seat-lease correctly blocked me from *running* the suite (test-runner = mutating; the authoring session holds the seat), so the "940 runs green" claim is verified statically + by the commit hook that will run it — everything else below is my own evidence.

## Law-by-law verdicts

**1. Flag absent = byte-identical, zero cost — CONFIRMED.**
`return nil unless env["GAME_VSYNC_OFF"]` is the first statement of `apply`; `require "ffi"` and `GetModuleHandleA` live inside `sdl`, reached only via `lib ||= sdl` after the guard. Call site is `if (vsync = ...) puts`, so nil → no output. Grep: nothing in `src/ harness/ soak/ bin/ Rakefile` sets or reads the flag except the module + its test. Evidence: `tmp/t4/off.log` has no VSYNC line; canary gate (flag absent) = `GATE determinism: 12 captures byte-identical` + `GATE vision: PASS`. Only unconditional cost is the file `require` — the exact frame_probe precedent already in window.rb. (Pedantry: `GAME_VSYNC_OFF=""` is truthy in Ruby and would attempt release — same convention as `GAME_FRAME_PROBE`, consistent, not a defect.)

**2. Timebase untouched — CONFIRMED.**
Diff = one require + 7 constructor lines after `super`; `update`/`draw`/session pump byte-untouched, `git status` shows no sim/save/netplay files modified. Evidence the sim stream is flag-blind: `v14 first_special striker=2478 blocker=798 lobber=1218` identical across all three runs (OFF / FAILED / ON), and the ON run still paces at p50=16.4 — proving Gosu's update_interval timer (not the swap) owns the tick cadence, which was the real mechanism risk.

**3. Never fatal — CONFIRMED.**
`rescue ScriptError, StandardError` — LoadError < ScriptError is explicitly covered (the exact trap the law names); FFI::NotFoundError < LoadError; NoMethodError/TypeError < StandardError. The rescue is method-level, wrapping the whole body. Nothing plausible escapes (SystemExit/Interrupt/NoMemoryError are out-of-scope pathologies; segfault-by-bad-pointer is pre-empted by the two null checks before `FFI::Function.new`). Proven live: `on_attempt1_failed_path.log` prints the FAILED line then runs 7200 frames to a clean quit with `persist saved`.

**4. was=1 same-instance reasoning — CONFIRMED (sound).**
SDL_video.h (read live, line 2110 region): Get returns "0 as a safe default" when "there isn't a valid current context." A second/fresh SDL2 instance has no video init and no current context on the calling thread, so only the instance whose GL context gosu made current — the one that executed `SDL_GL_SetSwapInterval(1)` at Window.cpp:111 (verified verbatim in the installed gem) — can report 1. Reading 1 back through *our* handle therefore proves handle identity. Residual (non-blocking): the success line *carries* the proof but doesn't *gate* on it — a wrong-instance resolve would print `was=0 rc=-1` under the non-REFUSED wording; self-evidencing to a reader, but the code never asserts `was==1`.

**5. FFI correctness on x64 — CONFIRMED.**
Lifetime: GetModuleHandle takes no reference, but none is needed — SDL2.dll is pinned by gosu.so's import table for process life (Ruby never unloads C extensions), and no LoadLibrary means no leak. Signatures: HMODULE/FARPROC as `:pointer` (no int truncation on x64), `int(void)`/`int(int)` match the header declarations I read. Calling convention: begin_code.h confirms `SDLCALL = __cdecl`, and on x64 Windows stdcall/cdecl collapse into the one Microsoft x64 convention, so FFI's default is correct for both kernel32 and SDL. (This module is 32-bit-hostile — kernel32 would need stdcall — but the repo is structurally x64: the i386 `lib/SDL2.dll` can't even load, proven by the banked error 193.)

**6. Doc vs code vs logs — CONFIRMED.**
Every quoted number re-checked against the raw logs: OFF `p50=16.5 p90=17.0 p99=17.4 max=54.5 over20=18 over35=3`, ON boot line `VSYNC off (swap_interval=0 was=1 rc=0)` + `p50=16.4 p90=16.8 p99=17.2 max=28.6 over20=9 over35=0`, attempt-1 `FAILED (LoadError: ... error 193 ...)` + OFF-matching pacing — all byte-exact. Save-chain digests prove run order and quarantine (scratch save sessions 1→2→3; real save md5 `98fe75...` identical before/after). Gem claims verified live: Window.cpp:111, gosu.rb `binary_path += "64"`, lib/=PE32 i386 (2,296,320 bytes exactly as doc states) vs lib64/=PE32+ x64, ffi 1.17.4-x64-mingw-ucrt in the lock, window.rb = 215 lines. Two sub-claims I flag: the suite line (UNCERTAIN from this seat — see preamble; hook enforces it at commit) and doc §5's canary "result below" placeholder is **unfilled** even though the pass is banked (`tmp/t4/canary_gate.log`, `_gate-verdicts.log` verdict PASS) — paste the one-line result before shipping the doc.

**7. Test quality — CONFIRMED.**
Traced all four against the implementation: (1) poison test is sound even against the rescue — a touched BasicObject raises NoMethodError, which `apply` would convert to a FAILED *string*, failing `assert_nil` loudly either way; (2) success test pins the exact line AND exactly one `Set(0)` via `set_calls == [0]`; (3) refusal is detected by read-back (`now != 0`), not by trusting rc — stronger than the naive design, and pinned with rc=-1; (4) failure test raises LoadError specifically, directly regression-pinning the ScriptError-not-StandardError trap. Real coverage hole (non-blocking): nothing pins that `require "ffi"` stays lazy — hoisting it to file top keeps all tests and the canary green while silently loading ffi in every boot including the wall. Blast radius is load-time only, but it's the one law a regression could erode invisibly.

## Defects found (all non-blocking)

- Doc §5 canary result placeholder unfilled (evidence exists banked; paste it).
- "ONE named line" is cosmetically violable: attempt-1's live FAILED line spans two lines because FFI's `e.message` embeds a newline. The shipped handle-path raises single-line messages, but foreign `e.message`s aren't sanitized (`e.message.gsub("\n", " ")` would close it).
- Success wording doesn't assert `was==1` (law 4 residual).
- Lazy-`require "ffi"` unpinned by tests (law 7 residual).

## Biggest risk NOT addressed

**Software-timer pacing quality on the one machine that matters.** Releasing vsync hands pacing to Gosu's update_interval sleep; on Junior's 2011-era machine, Windows' default ~15.6 ms timer granularity can quantize that sleep into 15.6/31.2 ms beats — the flag could trade the steady 59 Hz ceiling for irregular judder plus tearing on exactly the seat it's meant to help, and there is no tearing/judder oracle beyond frame_probe percentiles plus Junior's subjective report. Mitigated by design (env-gated, owner-paced A/B, REFUSED/negative outcomes pre-declared valid in §4) — but the ticket never names timer granularity as the failure mode to watch for in his numbers (a widened p50 *spread* with p50 ≈ 16.7 would be its signature).

FRESH-EYES VERDICT: PASS
