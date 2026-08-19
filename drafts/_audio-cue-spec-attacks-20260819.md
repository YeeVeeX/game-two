# Audio v1.1 — cue spec: ataques y efectos (2026-08-19)

Owner ask #2 (2026-08-19, chat, recorded in `_m5a-verdict-20260818.md`
§post-close): "and also add sounds for attacks and other effects".
Blocked ONLY on material: the owner-originals law (2026-08-18) means no
sound ships until his renders exist. This file is the drop-in plan —
when the renders land (same handoff shape: `game-two-audio/handoff/`
manifest with sha256s, or the assets exports lane), the mapping rows
below go into `data/audio/cues.json` unchanged.

## Para el dueño — lista de sonidos para crear en Reaper (es-CR)

Formato: WAV mono 48 kHz (igual que la primera tanda). Duraciones
aproximadas — lo que suene bien a su oído manda. Nombres sugeridos con
la duración en el nombre, como la tanda anterior:

1. **`msfx_hit_200ms`** — golpe que conecta (percusivo, seco, ~0.2 s).
   Suena MUCHAS veces por minuto: mejor cortito y sin cola.
2. **`msfx_special_600ms`** — casteo del ataque especial (~0.6 s, con
   más cuerpo; uno genérico sirve para los tres kits en esta pasada).
3. **`msfx_dodge_150ms`** — esquive (whoosh de aire, ~0.15 s).
4. **`msfx_death_400ms`** — muerte de un enemigo (~0.4 s).
5. **`msfx_wipe_1500ms`** — caída del grupo entero (~1.5 s, descendente,
   con peso — es el momento más dramático).
6. **`msfx_heal_300ms`** — usar una provisión (~0.3 s, orgánico).
7. **`msfx_throw_200ms`** — proyectil lanzado (~0.2 s).

Con que estén 1, 2 y 4 ya se siente el combate; el resto suma. Cuando
los tenga: expórtelos y avíseme — entran directo con estas filas.

## Mapping rows (mechanical — one cue per event, payload-blind per the
## v1 contract; gains interim at the +12 dB family until the LUFS lane)

| event | cue | file | bus | priority | notes |
|---|---|---|---|---|---|
| attack_hit | hit | msfx_hit_200ms | sfx | 30 | fires per landed hit — short, no duck |
| special_started | special_cast | msfx_special_600ms | sfx | 60 | one generic cast v1.1 |
| dodged | dodge_whoosh | msfx_dodge_150ms | sfx | 25 | |
| actor_died | death | msfx_death_400ms | sfx | 55 | payload-blind: same sound pack/human this pass |
| pack_wiped | wipe | msfx_wipe_1500ms | sfx | 95 | duck music −12 dB like the stingers |
| provision_used | heal | msfx_heal_300ms | ui | 50 | |
| projectile_fired | throw | msfx_throw_200ms | sfx | 20 | |

Constraints that bind the rows: sfx bus −10 dB headroom law; voice pool
sfx cap 48 with steal order (hit spam is safe); duck hold ≥ tick_frames;
`actor_died` gets ONE cue — per-faction variants need payload filters =
audio-seat custody (recorded, not asked yet). Events verified against
`Game::World::EVENTS` (all seven exist on the bus today).

## Status

- Renders: PENDING (owner's Reaper session, his pace).
- Mapping: ready above; lands as a data-only `cues.json` change +
  fixture entries (sha-pinned conversion, same 24→16 pipeline as v1).
- Verification at landing: AudioData.load structural check + suite +
  owner ear-check in his next play session (listen-verdict precedent).
