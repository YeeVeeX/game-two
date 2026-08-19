# CLAUDE.md — read AGENTS.md first

**`AGENTS.md` is the single ground truth for this repo** — contract, laws,
commands, gates. This file exists only so Claude sessions (Junior's seat)
load the same contract as every other agent. If this file and AGENTS.md ever
disagree, AGENTS.md wins.

Start of every session, in order:

1. Read `AGENTS.md` fully (scope block first — it moves; the live file beats
   any memory or prompt).
2. `git pull --ff-only` before working; pull again before every push
   (two peer seats share this repo — same-commit handshake law for coop).
3. Machine specifics for Junior's seat (Ruby path, audio setup, pt-br
   surfaces, agent-session protocol): `docs/JUNIOR.md`.

Non-negotiables that bite hardest (detail in AGENTS.md — this is a reminder,
not a substitute): suite green via hooks (never `--no-verify`) · every visual
change through the blocking Rule 2 gate (`rake gate`) · all tunables in
`data/**/*.json` · no lore/fiction names anywhere (standing order) · bot logs
are never fun-verify evidence · explicit-path commits, conventional messages.

— Ambos asientos son pares: ideas, código y dirección creativa valen igual
desde cualquiera de los dos. / Os dois assentos são pares: ideias, código e
direção criativa valem igual vindo de qualquer um dos dois.
