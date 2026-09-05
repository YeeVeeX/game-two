# A3 — ally brain flip (`threat.json ally.enabled` / `human.enabled`): stream-diff audit + player evidence

Junior seat, 2026-09-05 20:05. For the owner's line on amendment A3 (foundation
§RATIFICATION OPEN item 3: "the companion-brain flip is its own gated piece
inside T2 under the canary law"). Nothing here is applied: `main` still ships
the brain OFF; this is the audit the law asks for, so the decision can be made
on facts.

## 1. What the flip does (595b3ab + d626550, all pure sim-state rules)

Free allies (uncontrolled pack bodies): focus fire (leader's target, then finish
<35% hp) · drink a flask below 45% hp (`World#ally_sustain`, drink only) · dodge
a PROVOKED human's telegraph aimed at THIS body · role by attack arc (projectile:
hold 3 tiles + line up the shot + volley special; ring: ring special with ≥1
adjacent; front1+dash: dash special when aligned 2..max tiles). Humans: kit
`coward:true` (husk) retreats below 25% hp. Presentation (already on `main`,
brain-independent): ally callouts (flask / roll / special) + HUD row pulse.

## 2. Player evidence — one player (Junior), one scratch save, same start

| session | brain | callouts | length | fights | kill-xp | wipes | deaths | ZONE 5 | BOSS 1 | flasks | close |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 19:07 | OFF | – | 26 min | 1 | 292 | 0 | 0 | – | – | 0 | looked at the city ("o visual me prendeu") |
| 19:37 | OFF | – | 2 min | 1 | 70 | 0 | 1 (Pomo) | – | – | 0 | taunt → 19 retargets, lobber died ("a cidade tá mais dura") |
| 19:42 | **ON** | no | 2 min | 5 | 1230 | **2** | 4 | 39 s · 8 kills | **defeated** | 3 | "não notei diferença nos aliados" |
| 19:55 | **ON** | **yes** (+drink .45, ring_min 1) | 4 min | **11** | **3440** | **0** | 1 (corpse recovered) | **74 s · 27 kills · 0 deaths** | **defeated** | 3 | Aro ring 12 casts/8 kills · banked 451 · all three alive · **"vi o Pomo beber, o Aro fechar o anel; joguei junto"** |

Reading: the brain acted identically in 19:42 and 19:55 (same rules, same
route); what changed was (a) the player SEES the ally act, (b) the acts come
earlier. Silent brain = more deaths (the player pushes deeper without knowing
who covers him); announced brain = the pack survives. The companion "earned its
price" only when it was legible.

## 3. Stream diff — canaries OFF vs ON, same seed + inputs (`tools/a3_stream_diff.rb`, re-runnable: `ruby tools/a3_stream_diff.rb world_loop brasa2_run floor3_run`; the §4 trace = `ruby tools/a3_leash_trace.rb`)

All three OFF hashes equal the ACTIVE bank (the brain-OFF code path is
byte-inert, as the suite's canary test already proves). ON diverges at the
first tick a free ally makes a decision the old controller would not have:
| script | OFF md5 | = ACTIVE bank? | ON md5 | lines OFF -> ON | first divergent line |
|---|---|---|---|---|---|
| world_loop | `e0b1f38f` | YES | `6850a028` | 42 -> 43 | 11 of 42 |
| brasa2_run | `3fd04895` | YES | `7445f630` | 82 -> 255 | 18 of 82 |
| floor3_run | `648810ff` | YES | `e14bafe4` | 155 -> 260 | 4 of 155 |

### world_loop

First divergence at line 11 (prefix of 10 lines byte-identical):

```
  OFF: EVENT projectile_fired frame=468 attacker=lobber
   ON: EVENT special_started frame=458 attacker=lobber
```

Event-class deltas (count OFF -> ON):

| class | OFF | ON |
|---|---|---|
| attack_hit | 13 | 9 |
| human_respawned | 1 | 3 |
| human_retargeted | 4 | 6 |
| special_started | 0 | 2 |
| telegraph | 6 | 4 |
| banked | 1 | 0 |
| dodged | 0 | 1 |
| drop_picked_up | 1 | 0 |
| respawn_telegraphed | 2 | 3 |
| taunted | 0 | 1 |

### brasa2_run

First divergence at line 18 (prefix of 17 lines byte-identical):

```
  OFF: EVENT human_retargeted frame=248 actor=ember_a5 from=nil to=lobber cause=acquired
   ON: EVENT attack_hit frame=248 attacker=blocker victim=ember_a4 kind=attack landed=true
```

Event-class deltas (count OFF -> ON):

| class | OFF | ON |
|---|---|---|
| human_leashed | 0 | 93 |
| human_retargeted | 15 | 107 |
| attack_hit | 27 | 20 |
| telegraph | 9 | 5 |
| drop_decayed | 7 | 4 |
| special_started | 0 | 2 |
| actor_died | 9 | 8 |
| drop_spawned | 9 | 8 |
| fight_resolved | 1 | 2 |
| projectile_fired | 3 | 4 |

### floor3_run

First divergence at line 4 (prefix of 3 lines byte-identical):

```
  OFF: EVENT human_retargeted frame=132 actor=spore_a4 from=nil to=blocker cause=acquired
   ON: EVENT special_started frame=132 attacker=lobber
```

Event-class deltas (count OFF -> ON):

| class | OFF | ON |
|---|---|---|
| attack_hit | 46 | 65 |
| human_respawned | 7 | 19 |
| human_retargeted | 17 | 28 |
| telegraph | 17 | 27 |
| projectile_fired | 10 | 19 |
| special_started | 0 | 9 |
| actor_died | 15 | 23 |
| drop_decayed | 13 | 21 |
| drop_spawned | 15 | 22 |
| respawn_telegraphed | 7 | 14 |
| fight_resolved | 3 | 6 |
| dodged | 0 | 2 |

### Divergence classes, explained

- `special_started` 0 → N, `dodged` 0 → N: the brain's own verbs (rules 4/3).
- `attack_hit` / `actor_died` / `drop_*` / `human_respawned` up (floor3_run): the
  pack fights MORE — focus fire + specials + flask-sustain keep three bodies
  alive and killing where the old pack idled.
- `telegraph` down (world_loop, brasa2): allies shoot first / step out of range
  before the human's windup starts.
- `human_retargeted` up everywhere: allies MOVE (hold distance, align, dodge), so
  the humans' focus re-evaluates more often. Expected.
- **`human_leashed` 0 → 93 in brasa2_run: a FINDING, not combat.** See §4.

## 4. Finding — the ranged-hold STALEMATE (brasa2_run, brain ON)

leashed por ator: {"ember_a5" => 1, "ember_a6" => 3, "ember_a9" => 46, "ember_a13" => 43}
frames leashed (primeiros 30): [399, 497, 611, 704, 899, 969, 1071, 1212, 1351, 1492, 1631, 1772, 1911, 2052, 2191, 2332, 2471, 2612, 2751, 2892, 3031, 3172, 3311, 3452, 3591, 3732, 3871, 4012, 4151, 4292]
gaps: min=70 max=195 mediana=139
--- linha do tempo de ember_a9 (retarget/leash/died), primeiras 24 ---
  EVENT human_retargeted frame=267 actor=ember_a9 from=nil to=striker cause=acquired
  EVENT human_retargeted frame=343 actor=ember_a9 from=striker to=lobber cause=acquired
  EVENT human_leashed frame=704 actor=ember_a9 tile=[7, 2] hp=65 steered=false
  EVENT human_retargeted frame=705 actor=ember_a9 from=nil to=lobber cause=acquired
  EVENT human_retargeted frame=809 actor=ember_a9 from=nil to=lobber cause=acquired
  EVENT human_leashed frame=969 actor=ember_a9 tile=[7, 2] hp=65 steered=false
  EVENT human_retargeted frame=970 actor=ember_a9 from=nil to=lobber cause=acquired
  EVENT human_leashed frame=1071 actor=ember_a9 tile=[7, 2] hp=65 steered=false

Two `ember_a` (a9: 46, a13: 43) sit on their home tile from frame ~700 to the
end: cadence leash → re-acquire the lobber ONE frame later → leash again, every
~280 frames, hp frozen (65) — no damage either way. Mechanism: the lobber holds
3 tiles and lines up its shot (rule 4), the ember never closes the gap (blocked
path / pressure slot) and never disengages (target stays in aggro range). Not a
crash, not a determinism break (byte-identical ×2), not present with the brain
OFF: a positioning STALEMATE the brain creates. Two fix candidates, neither
applied (they change the brain's behavior = owner's call):

- (a) **ally advances when its target cannot reach it**: if the focused human
  has not moved for N frames and is out of its own attack range, the ranged ally
  closes one tile (data: `ally.stalemate_frames`).
- (b) **ember leash-and-forget**: a human that leashed with the same target still
  in range drops that target for `leash_forget_frames` (data), so it re-paths
  or goes home for good.

## 5. Recommendation (dev)

Flip A3 ON as its own gated piece (T2), with §4 as a NAMED follow-up piece
inside the same ticket (fix (a) preferred: it is the ally's brain that created
the pocket, the ally should close it). Rebank the three canaries under the
versioned protocol with this document as the stream-diff audit. The player
evidence (§2) says the companion earns its price when it is legible; the
callouts are already on `main`.
