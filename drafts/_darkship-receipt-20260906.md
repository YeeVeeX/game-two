# DARK-SHIP receipt - 2026-09-06 23:2x - junior/premium-build @ c4a908d vs origin/main @ d4bb6e4

Gabriel s138, option (c): the proof that matters = EVENT streams byte-identical to main with the keys OFF.
Method: `ruby tools/manifest_census.rb --md5` in a detached worktree at origin/main and in the branch (same seeds, same
Harness.apply_start / expand_script / EventLog list; md5 over every EVENT line of the run). economy.json item_drops_enabled=false,
status.json burn.enabled=false (the shipped defaults).

RESULT: 42 / 42 world scripts IDENTICAL; differing: 0 (menu_tour / moving_square are not world scenarios: not judged).

Canaries (tools/a3_stream_diff.rb): world_loop f023e3dd YES · brasa2_run 3fd04895 YES · floor3_run 648810ff YES.
Suite: 1595 runs / 0 failures. Census (manifests): 44 scripts ALL PASS.

## md5 per script (main == branch)
```
aim_hold               53aa7410f191bc0c1d061fd6bb177c48
aoe_specials           833a9c5480230ada81fcc04aa9f3c5c7
basement_pocket        4871350bff33f71158f4b468c53781fd
blink_arrival          4b84debba8bab06c7db0425ab9f788f5
boss1_writ             e9a611646e09fc803b4132d78a8002a6
boss2_phases           9b0ee7d21e070be3865d6b9b96b443e8
boss4_phases           020367a94670904749f9283960418fe4
brasa1_run             7a6acbc84815a07625a9d3fd5c571bbd
brasa2_run             3fd04895ccd8dd053f784de7223a1697
brasa3_run             bf7eb904ff85a440aba742a485882a06
corpse_run             97db020589d67b55005f301c993abe42
critic_reel            68e0c5937a9a7d7793eafdfb22b59eb8
dash_strike_rip        8d6da52e6b27b5d21351ef6b8cb1e89b
district_hunt          1e3605d738bb00cd2cb0e636ade3f86b
floor1_run             2f293a01cff9cb218ba2b30c08535482
floor2_run             0582ddc71f3356311f5447a023823af8
floor3_run             648810ff4faa2123aae7c7d736a5d9df
grass_fixture_walk     9bbe69f6c2fb559553ebd45fc1cc0cba
ledger_loop            3a2287b6b6d87e8b3bad87e0754094eb
level_gate             e547faae6ccbd8889f04824d1ee2e4be
level_up_beat          5cfcc4fe55baa7d18f78fd98d84e9c53
lobber_reach           911b54b4ee0ed47c4c26b606aa17e204
lobber_volley          a190e3241bfb1c9bdfd6121e740935d9
mercy_floor            21a3add8c896dd2f75d54d9104b0f87d
multi_floor_descent    d30d295332116509d3a9cef38e8be534
respawn_telegraph      09aad3fd4e4eea0ce044fc225a04f388
safe_boundary          12b0828d07b4f554c9052afc2e0a46b2
specials_chain         f2817329345cb72d3570132afb4e44c2
sustain_run            f704aaac3facce4256f5135cedff43f7
taunt_anchor           a80da1f80d03d89ea52465eeb360014f
threat_pull            a27ec00138d09f64a8304b956b150784
toll_pocket            0ef2b18c856a85fa148f73d2e473635d
totem_pulse            78d697f9319efdabbb052d8953a81b3c
tower2_run             a2d4b3e1a2ec49131d979b0b7143b7fa
tower3_run             61d60bd017cd7fa493d37e913e3bd28e
tower4_run             7dc95f7c7e66fd78f3217ca0f0884151
town_gates             2f99c4e988def216d5b27699bebab995
vat_economy            747e2749d92ead7cd13951c4b72e7bb3
wall_fixture_walk      04caa81bc42a9b752340af6d44702123
world_loop             f023e3dd6d5f20e3fb5d090ef0c5bdb8
zone8_crossing         f63ad045db7938494686fc11a9406c41
zone_catchup           3bafdc1a27a4279b45a11a4a1d9403c1
```

## Review (fresh eyes, drafts/_review-darkship-freshEyes-20260906.md) - MERGEABLE (dark) WITH MINORS; every finding landed
- MAJOR: the burn-OFF test had landed OUTSIDE the class `end` (dead, 0 runs) -> moved inside; `-n` = 1 run / 3 assertions.
- `use_cure_item` now gated on `items_enabled?` (a bag loaded from a save written ON, then flipped OFF, must not act while OFF); the cure test opts items in on a fresh store.
- Method note: main's md5s came from a detached worktree of origin/main (the seat-lease debt Gabriel named in s138 applies here too; the reviewer reproduced 4/4 spot-checked md5s on the branch side).
- world.rb is 1728 lines (prose-number law).
- Residual of the stream proof, named: events outside the curated EventLog list (item_dropped, aura_burn, ...) and digest-only leaves (bag group, loot_rng_draws) are not covered by the md5; mixed-tree coop is REFUSED at HELLO by the data fingerprint (intended). Branch pins for HUD reels go STALE without the BAG chip (not a main regression).
