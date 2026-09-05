require_relative "../test_helper"
require "core/tile_map"
require "core/tile_registry"
require "core/data_store"

class TileMapTest < Minitest::Test
  def base_cfg
    {
      tile_size: 32,
      display_name: "T",
      palette: { floor: [0, 0, 0], grid: [0, 0, 0], wall: [0, 0, 0], transition: [0, 0, 0] },
      tiles: ["#####", "#...#", "#...#", "#...#", "#####"],
      pack_spawn: [[1, 1], [2, 1], [3, 1]]
    }
  end

  def test_stations_parse_and_lookup
    map = Core::TileMap.new(base_cfg.merge(stations: [{ type: "bank", at: [2, 2] }]))
    assert_equal({ type: "bank", at: [2, 2] }, map.station_at(2, 2))
    assert_nil map.station_at(1, 1)
  end

  def test_station_on_wall_raises_bad_map
    assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(base_cfg.merge(stations: [{ type: "bank", at: [0, 0] }]))
    end
  end

  def test_zones_without_stations_stay_valid
    assert_empty Core::TileMap.new(base_cfg).stations
  end

  # v20 T5 (foundation L11): the second wall char blocks EXACTLY like '#'
  # — one wall class, two render identities. Blocking is the frozen
  # WALL_CHARS set, never the registry.
  def test_percent_char_blocks_like_hash
    map = Core::TileMap.new(base_cfg.merge(tiles: ["#####", "#...#", "#..%#", "#...#", "#####"]))
    assert map.wall?(3, 2)
    refute map.passable?(3, 2)
    assert map.passable?(2, 2)
    assert_equal ["#", "%"], Core::TileMap::WALL_CHARS.sort
  end

  def test_spawn_on_percent_wall_refuses
    cfg = base_cfg.merge(tiles: ["#####", "#%..#", "#...#", "#...#", "#####"], pack_spawn: [[1, 1], [2, 1], [3, 1]])
    e = assert_raises(Core::TileMap::BadMap) { Core::TileMap.new(cfg) }
    assert_match(/pack_spawn \[1, 1\] is not passable/, e.message)
  end

  # v13 i18n: the renderer keys zone strings off the INTERNAL zone name
  # ("zone.<name>.display_name"); display_name stays the canonical EN text.
  def test_name_exposed_for_locale_keys
    assert_equal "t_zone", Core::TileMap.new(base_cfg.merge(name: "t_zone")).name
  end

  def test_name_optional_for_fixture_maps
    assert_nil Core::TileMap.new(base_cfg).name
  end

  # B1: the sanctuary flag — reader mirrors hub's plumbing exactly.
  def test_safe_reader_defaults_false
    refute Core::TileMap.new(base_cfg).safe
    assert Core::TileMap.new(base_cfg.merge(safe: true)).safe
  end

  # B1 D2 — the load invariant: a declared sanctuary cannot seed hostiles
  # (refusal NAMED, s34 seal-gating precedent); the message names the zone
  # and both keys so a future spawn-table pass collides loudly at boot.
  def test_safe_zone_with_enemy_spawns_refuses_named
    err = assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(base_cfg.merge(
                          name: "sanct", safe: true,
                          enemy_spawns: { rusher: [[2, 2]] }
                        ))
    end
    assert_match(/sanct/, err.message)
    assert_match(/safe: true/, err.message)
    assert_match(/enemy_spawns/, err.message)
  end

  def test_safe_zone_without_spawns_loads
    assert Core::TileMap.new(base_cfg.merge(safe: true, enemy_spawns: {})).safe
  end

  # T3: char + used-chars readers (footstep material derivation + the
  # used-chars scope law in TileRegistry#validate_map!).
  def test_char_at_reads_grid_and_nils_out_of_bounds
    map = Core::TileMap.new(base_cfg)
    assert_equal "#", map.char_at(0, 0)
    assert_equal ".", map.char_at(1, 1)
    assert_nil map.char_at(-1, 0)
    assert_nil map.char_at(0, -1)
    assert_nil map.char_at(99, 0)
    assert_nil map.char_at(0, 99)
  end

  def test_used_chars_lists_each_grid_char_once
    assert_equal ["#", "."], Core::TileMap.new(base_cfg).used_chars.sort
  end

  # --- schema v2 (world-builder T2): floors, typed transitions, regions,
  # tile-type ids. All additive — defaults preserve v1 files exactly.

  def registry
    Core::TileRegistry.new(
      "types" => {
        "wall" => { "char" => "#", "int_grid" => 1, "render" => "wall",
                    "footstep" => "stone", "passability" => "wall" },
        "floor" => { "char" => ".", "int_grid" => 2, "render" => "floor",
                     "footstep" => "stone", "passability" => "floor" }
      }
    )
  end

  def test_floor_defaults_to_zero
    assert_equal 0, Core::TileMap.new(base_cfg).floor
  end

  def test_floor_reads_negative_depth
    assert_equal(-1, Core::TileMap.new(base_cfg.merge(floor: -1)).floor)
  end

  def test_floor_non_integer_refuses
    e = assert_raises(Core::TileMap::BadMap) { Core::TileMap.new(base_cfg.merge(floor: "-1")) }
    assert_match(/floor must be an Integer/, e.message)
  end

  def test_typed_transitions_parse
    map = Core::TileMap.new(base_cfg.merge(
      transitions: [{ at: [2, 2], to: "below", spawn: [1, 1], type: "stairs_down" }]
    ))
    assert_equal "stairs_down", map.transition_at(2, 2)[:type]
  end

  def test_untyped_transition_stays_valid_v1_shape
    map = Core::TileMap.new(base_cfg.merge(
      transitions: [{ at: [2, 2], to: "next", spawn: [1, 1] }]
    ))
    assert_nil map.transition_at(2, 2)[:type]
  end

  def test_unknown_transition_type_refuses_named
    e = assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(base_cfg.merge(transitions: [{ at: [2, 2], to: "x", spawn: [1, 1], type: "elevator" }]))
    end
    assert_match(/unknown type "elevator"/, e.message)
  end

  def test_hole_may_declare_stairs_unlocked_by
    map = Core::TileMap.new(base_cfg.merge(
      transitions: [{ at: [2, 2], to: "below", spawn: [1, 1], type: "hole",
                      stairs_unlocked_by: "well_drained" }]
    ))
    assert_equal "well_drained", map.transition_at(2, 2)[:stairs_unlocked_by]
  end

  def test_stairs_unlocked_by_off_hole_refuses_named
    e = assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(base_cfg.merge(
        transitions: [{ at: [2, 2], to: "x", spawn: [1, 1], type: "stairs_down",
                        stairs_unlocked_by: "well_drained" }]
      ))
    end
    assert_match(/legal on type "hole" only/, e.message)
  end

  def test_stairs_unlocked_by_needs_fact_name
    e = assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(base_cfg.merge(
        transitions: [{ at: [2, 2], to: "x", spawn: [1, 1], type: "hole", stairs_unlocked_by: "" }]
      ))
    end
    assert_match(/non-empty breach-family fact/, e.message)
  end

  # --- T4: the boss fact-gate + the well's drained-look link -------------

  def test_requires_defeats_parses_on_any_transition
    map = Core::TileMap.new(base_cfg.merge(
      transitions: [{ at: [2, 2], to: "next", spawn: [1, 1], requires_defeats: 1 }]
    ))
    assert_equal 1, map.transition_at(2, 2)[:requires_defeats]
  end

  def test_requires_defeats_refuses_non_positive_or_non_integer
    [0, -1, "1", 1.5].each do |bad|
      e = assert_raises(Core::TileMap::BadMap) do
        Core::TileMap.new(base_cfg.merge(
          transitions: [{ at: [2, 2], to: "x", spawn: [1, 1], requires_defeats: bad }]
        ))
      end
      assert_match(/requires_defeats must be an Integer >= 1/, e.message)
    end
  end

  # --- T5 (P9): the level fact-gate — requires_defeats' full sibling ----

  def test_requires_level_parses_on_any_transition
    map = Core::TileMap.new(base_cfg.merge(
      transitions: [{ at: [2, 2], to: "next", spawn: [1, 1], requires_level: 2 }]
    ))
    assert_equal 2, map.transition_at(2, 2)[:requires_level]
  end

  def test_requires_level_refuses_non_positive_or_non_integer
    [0, -1, "2", 2.5].each do |bad|
      e = assert_raises(Core::TileMap::BadMap) do
        Core::TileMap.new(base_cfg.merge(
          transitions: [{ at: [2, 2], to: "x", spawn: [1, 1], requires_level: bad }]
        ))
      end
      assert_match(/requires_level must be an Integer >= 1/, e.message)
    end
  end

  def test_requires_level_coexists_with_requires_defeats
    # Independent AND branches (the s34 comment law): one way may carry
    # both facts and both validate.
    map = Core::TileMap.new(base_cfg.merge(
      transitions: [{ at: [2, 2], to: "next", spawn: [1, 1],
                      requires_defeats: 1, requires_level: 3 }]
    ))
    assert_equal 1, map.transition_at(2, 2)[:requires_defeats]
    assert_equal 3, map.transition_at(2, 2)[:requires_level]
  end

  def test_water_drained_by_parses_with_authored_palette_ref
    cfg = base_cfg
    cfg[:palette] = cfg[:palette].merge(water_drained: [9, 9, 9])
    map = Core::TileMap.new(cfg.merge(water_drained_by: [2, 2]))
    assert_equal [2, 2], map.water_drained_by
  end

  def test_water_drained_by_defaults_nil
    assert_nil Core::TileMap.new(base_cfg).water_drained_by
  end

  def test_water_drained_by_refuses_out_of_bounds_or_bad_shape
    cfg = base_cfg
    cfg[:palette] = cfg[:palette].merge(water_drained: [9, 9, 9])
    [[9, 9], [2], ["2", "2"], [-1, 1]].each do |bad|
      e = assert_raises(Core::TileMap::BadMap) { Core::TileMap.new(cfg.merge(water_drained_by: bad)) }
      assert_match(/water_drained_by must be an in-bounds \[x, y\] tile/, e.message)
    end
  end

  def test_water_drained_by_refuses_without_drained_palette_ref
    e = assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(base_cfg.merge(water_drained_by: [2, 2]))
    end
    assert_match(/palette carries no water_drained ref/, e.message)
  end

  def test_regions_parse_as_data_layer
    map = Core::TileMap.new(base_cfg.merge(
      regions: [{ id: "town_1", rect: [1, 1, 3, 2], intent: "town" }]
    ))
    assert_equal [{ id: "town_1", rect: [1, 1, 3, 2], intent: "town" }], map.regions
  end

  def test_regions_default_empty
    assert_empty Core::TileMap.new(base_cfg).regions
  end

  def test_region_duplicate_id_refuses
    e = assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(base_cfg.merge(regions: [
        { id: "a", rect: [1, 1, 1, 1], intent: "town" },
        { id: "a", rect: [2, 2, 1, 1], intent: "guard" }
      ]))
    end
    assert_match(/duplicate region id "a"/, e.message)
  end

  def test_region_unknown_intent_refuses
    e = assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(base_cfg.merge(regions: [{ id: "a", rect: [1, 1, 1, 1], intent: "casino" }]))
    end
    assert_match(/unknown intent "casino"/, e.message)
  end

  def test_region_rect_outside_map_refuses
    e = assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(base_cfg.merge(regions: [{ id: "a", rect: [3, 3, 4, 1], intent: "town" }]))
    end
    assert_match(/outside 5x5 map/, e.message)
  end

  def test_region_rect_bad_shape_refuses
    e = assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(base_cfg.merge(regions: [{ id: "a", rect: [1, 1, 2], intent: "town" }]))
    end
    assert_match(/rect must be \[x, y, w, h\]/, e.message)
  end

  def test_tile_types_normalizes_symbolized_keys
    map = Core::TileMap.new(base_cfg.merge(tile_types: { "#": "wall", ".": "floor" }))
    assert_equal({ "#" => "wall", "." => "floor" }, map.tile_types)
  end

  def test_tile_types_default_nil
    assert_nil Core::TileMap.new(base_cfg).tile_types
  end

  def test_tile_types_unknown_type_refuses_under_registry
    map = Core::TileMap.new(base_cfg.merge(tile_types: { ".": "lava" }))
    e = assert_raises(Core::TileMap::BadMap) { registry.validate_map!(map) }
    assert_match(/"lava": unknown tile type/, e.message)
  end

  def test_registry_render_ref_must_exist_in_palette
    cfg = base_cfg
    cfg[:palette] = cfg[:palette].reject { |k, _| k == :floor }
    map = Core::TileMap.new(cfg)
    e = assert_raises(Core::TileMap::BadMap) { registry.validate_map!(map) }
    assert_match(/renders palette ref "floor", absent/, e.message)
  end

  # --- s32: tile-shape law (s31 review nit 1) — every tile reaching
  # check_passable! refuses NAMED on bad shape instead of splitting into
  # UNNAMED crashes (nil, string pairs) or silent mis-validation (Float
  # truncation under Array#[], 3-element tails dropped — tiles that
  # validated against the WRONG coordinates while transition_at's ==
  # never matched: DEAD transitions). One case per live-probed mode.

  def test_nil_transition_at_refuses_named
    e = assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(base_cfg.merge(transitions: [{ at: nil, to: "x", spawn: [1, 1] }]))
    end
    assert_match(/transition must be an \[x, y\] tile \(got nil\)/, e.message)
  end

  def test_string_pair_tile_refuses_named
    e = assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(base_cfg.merge(transitions: [{ at: ["3", "1"], to: "x", spawn: [1, 1] }]))
    end
    assert_match(/transition must be an \[x, y\] tile \(got \["3", "1"\]\)/, e.message)
  end

  def test_float_tile_refuses_named_instead_of_truncating
    # The silent-corruption kill: Array#[] truncated 1.5 -> validated
    # CLEAN against tile [1, 1], then the transition never matched == at
    # runtime — a DEAD transition, not a crash.
    e = assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(base_cfg.merge(transitions: [{ at: [1.5, 1], to: "x", spawn: [1, 1] }]))
    end
    assert_match(/transition must be an \[x, y\] tile \(got \[1\.5, 1\]\)/, e.message)
  end

  def test_three_element_tile_refuses_named_instead_of_dropping_tail
    e = assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(base_cfg.merge(transitions: [{ at: [1, 1, 9], to: "x", spawn: [1, 1] }]))
    end
    assert_match(/transition must be an \[x, y\] tile \(got \[1, 1, 9\]\)/, e.message)
  end

  def test_nil_pack_spawn_entry_refuses_named
    e = assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(base_cfg.merge(pack_spawn: [[1, 1], [2, 1], nil]))
    end
    assert_match(/pack_spawn must be an \[x, y\] tile \(got nil\)/, e.message)
  end

  def test_string_gradient_anchor_refuses_named
    e = assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(base_cfg.merge(gradient_anchor: "middle"))
    end
    assert_match(/gradient_anchor must be an \[x, y\] tile \(got "middle"\)/, e.message)
  end

  def test_legal_integer_tiles_stay_valid_through_the_guard
    # The legal control, named explicitly (every construction in this
    # file already routes through the guard — this one asserts it).
    map = Core::TileMap.new(base_cfg.merge(
      transitions: [{ at: [2, 2], to: "next", spawn: [1, 1] }],
      gradient_anchor: [3, 3]
    ))
    assert_equal [2, 2], map.transition_at(2, 2)[:at]
    assert_equal [3, 3], map.gradient_anchor
  end

  # --- s33: seal opens law (the refusal RECORDED s31 + s32, promoted).
  # A seal's opens is consumed BLIND downstream (interact_seal ->
  # breached?/spend_banked/restore_breach!; price sheet pre-breach) — an
  # ill-shaped opens or one naming NO transition burns the toll, opens
  # nothing, and persists the inert fact into the save. Refuse NAMED at
  # load; message asserted per mode.

  def seal_cfg(opens:, transitions: [])
    base_cfg.merge(
      stations: [{ type: "seal", at: [1, 1], price: "breach_cost", opens: opens }],
      transitions: transitions
    )
  end

  def test_seal_nil_opens_refuses_named
    e = assert_raises(Core::TileMap::BadMap) { Core::TileMap.new(seal_cfg(opens: nil)) }
    assert_match(/seal at \[1, 1\]: opens must be an \[x, y\] tile \(got nil\)/, e.message)
  end

  def test_seal_string_pair_opens_refuses_named
    e = assert_raises(Core::TileMap::BadMap) { Core::TileMap.new(seal_cfg(opens: ["3", "3"])) }
    assert_match(/seal at \[1, 1\]: opens must be an \[x, y\] tile \(got \["3", "3"\]\)/, e.message)
  end

  def test_seal_float_opens_refuses_named_instead_of_truncating
    e = assert_raises(Core::TileMap::BadMap) { Core::TileMap.new(seal_cfg(opens: [3.0, 3])) }
    assert_match(/seal at \[1, 1\]: opens must be an \[x, y\] tile \(got \[3\.0, 3\]\)/, e.message)
  end

  def test_seal_three_element_opens_refuses_named_instead_of_dropping_tail
    e = assert_raises(Core::TileMap::BadMap) { Core::TileMap.new(seal_cfg(opens: [3, 3, 9])) }
    assert_match(/seal at \[1, 1\]: opens must be an \[x, y\] tile \(got \[3, 3, 9\]\)/, e.message)
  end

  def test_seal_out_of_bounds_opens_refuses_named
    # Bounds reads differently from no-transition: a coordinate typo off
    # the map is not "authored a floor tile there".
    e = assert_raises(Core::TileMap::BadMap) { Core::TileMap.new(seal_cfg(opens: [9, 9])) }
    assert_match(/seal at \[1, 1\]: opens \[9, 9\] outside 5x5 map/, e.message)
  end

  def test_seal_opens_naming_no_transition_refuses_named
    # The semantic kill: legal shape, in bounds, NO transition there —
    # the seal that eats tolls and opens nothing.
    e = assert_raises(Core::TileMap::BadMap) { Core::TileMap.new(seal_cfg(opens: [3, 3])) }
    assert_match(/seal at \[1, 1\]: opens \[3, 3\] names no transition/, e.message)
  end

  def test_seal_opening_a_real_transition_stays_valid
    map = Core::TileMap.new(seal_cfg(
      opens: [3, 3],
      transitions: [{ at: [3, 3], to: "next", spawn: [1, 1], sealed: true }]
    ))
    assert_equal [3, 3], map.station_at(1, 1)[:opens]
  end

  # --- s34: seal GATING law (s33 review nit 1, grilled + promoted). A
  # breach fact is read ONLY through a transition's truthy sealed flag
  # (Crossing#open?, Renderer.way_locked?) — a seal onto an unsealed way
  # burns the toll, prints TOLL PAID, and changes nothing. Message
  # asserted per mode; the composition control pins that requires_defeats
  # co-existing with sealed: true stays legal (independent AND branches).

  def test_seal_opens_naming_an_unsealed_transition_refuses_named
    e = assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(seal_cfg(
        opens: [3, 3],
        transitions: [{ at: [3, 3], to: "next", spawn: [1, 1] }]
      ))
    end
    assert_match(/seal at \[1, 1\]: opens \[3, 3\] names an unsealed transition/, e.message)
  end

  def test_seal_opens_naming_a_sealed_false_transition_refuses_named
    # The hand-edit shape: sealed present but false is the same lie —
    # truthiness matches the consumers' read, never key presence. (The
    # importer never emits this: import_ldtk drops falsy sealed — hand-
    # edited zones are the exposed path, the s33 rationale unchanged.)
    e = assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(seal_cfg(
        opens: [3, 3],
        transitions: [{ at: [3, 3], to: "next", spawn: [1, 1], sealed: false }]
      ))
    end
    assert_match(/names an unsealed transition/, e.message)
  end

  def test_seal_opens_naming_a_fact_gated_unsealed_transition_refuses_named
    # The grill's question (b) pinned: requires_defeats gates on the boss
    # counter, NOT the breach — without sealed the toll can never open
    # this way ("toll bypasses the boss gate" would be an open? sim
    # change, not authoring).
    e = assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(seal_cfg(
        opens: [3, 3],
        transitions: [{ at: [3, 3], to: "next", spawn: [1, 1], requires_defeats: 1 }]
      ))
    end
    assert_match(/names an unsealed transition/, e.message)
  end

  def test_seal_opens_naming_a_level_gated_unsealed_transition_refuses_named
    # T5 belt: the sibling composes with s34 for free — the gating law
    # reads t[:sealed] only, so a requires_level-only way refuses as a
    # seal target with ZERO new validator code (the existing message).
    e = assert_raises(Core::TileMap::BadMap) do
      Core::TileMap.new(seal_cfg(
        opens: [3, 3],
        transitions: [{ at: [3, 3], to: "next", spawn: [1, 1], requires_level: 2 }]
      ))
    end
    assert_match(/names an unsealed transition/, e.message)
  end

  def test_seal_opening_a_sealed_and_fact_gated_transition_stays_valid
    map = Core::TileMap.new(seal_cfg(
      opens: [3, 3],
      transitions: [{ at: [3, 3], to: "next", spawn: [1, 1], sealed: true, requires_defeats: 2 }]
    ))
    assert_equal [3, 3], map.station_at(1, 1)[:opens]
  end

  # T2 regression bar, T4 amendment + v20 T1: the live-world zones stay
  # their recorded shapes; the T3 fixture + the four T4 pilot zones + the
  # graduated district (v20 T1 — floor -1, typed descent ways through the
  # importer door) are the authored v2 surface. camp carries exactly ONE
  # typed row (the descent MOUTH, stairs_down into district — v20 L2);
  # every other live gate stays untyped v1 — the byte-exact bar. zone_8 is
  # the worldsmith-intake zone (2026-08-23), wired s70: reachable through
  # dungeon_1's rope way, its own return stays a plain v1 edge gate.
  def test_live_zones_load_under_registry_with_declared_shapes
    data = Core::DataStore.new("data")
    reg = Core::TileRegistry.new(data["tiles"])
    zones = data.keys.grep(%r{\Azones/})
    assert_equal 20, zones.length # FASE 6.3-6.7: + dungeon_2/3/4 (tower) + ember_1/2/3 (BRASA)
    v1 = %w[zones/camp zones/slow_door]
    pilot = %w[zones/zone_7 zones/basement_1 zones/basement_2 zones/dungeon_1 zones/dungeon_2 zones/dungeon_3 zones/dungeon_4 zones/ember_1 zones/ember_2 zones/ember_3
               zones/district zones/district_two zones/low_quay]
    zones.each do |key|
      map = Core::TileMap.new(data[key])
      reg.validate_map!(map)
      if pilot.include?(key)
        map.transitions.each do |t|
          assert_includes Core::TileMap::TRANSITION_TYPES + [nil], t[:type]
        end
      elsif key == "zones/camp"
        assert_equal 0, map.floor, "the hub stays surface (floor 0)"
        map.transitions.each do |t|
          next if t[:to] == "district" && t[:type] == "stairs_down" # the mouth
          assert_nil t[:type], "#{key}: only the descent mouth is typed"
        end
      else
        assert_equal 0, map.floor, "#{key} must default to floor 0"
        map.transitions.each { |t| assert_nil t[:type], "#{key} transitions stay untyped v1 gates" }
      end
      if v1.include?(key)
        assert_empty map.regions, "#{key} must default to no regions"
        assert_nil map.tile_types, "#{key} must carry no tile_types override"
      end
    end
    assert_equal({ "." => "dirt" }, Core::TileMap.new(data["zones/nest"]).tile_types)
    fixture = Core::TileMap.new(data["zones/grass_fixture"])
    assert_equal %w[plaza], fixture.regions.map { |r| r[:id] }
    assert_empty fixture.enemy_spawns, "the fixture zone is threat-free by data"
    # T5: the level-gate fixture (TEST 1) is SELF-LINKED — arrivals touch
    # only itself, so every ratified zone's beachhead/anchor geometry is
    # untouched by construction — and carries the one shipped
    # requires_level (the wall's Rule 2 surface for the P9 machinery).
    gate_fx = Core::TileMap.new(data["zones/gate_fixture"])
    gate_way = gate_fx.transition_at(12, 10)
    assert_equal "gate_fixture", gate_way[:to], "TEST 1 stays self-linked"
    assert_equal 2, gate_way[:requires_level]
    # T4 pilot shapes: the town hub anchors floor 0; the descent is FLOOR -1.
    z7 = Core::TileMap.new(data["zones/zone_7"])
    assert z7.hub, "ZONE 7 is the town anchor (camp precedent)"
    assert_equal 0, z7.floor
    assert_equal [33, 14], z7.water_drained_by
    assert_equal %w[town_1], z7.regions.map { |r| r[:id] }
    assert_empty z7.enemy_spawns, "ZONE 7 is threat-free by data, not by rules"
    %w[zones/basement_1 zones/basement_2 zones/dungeon_1 zones/district].each do |key|
      assert_equal(-1, Core::TileMap.new(data[key]).floor, "#{key} sits on FLOOR -1")
    end
    # v20 T6b: the descent's second step — ZONE 3 is FLOOR -2 (data honesty).
    assert_equal(-2, Core::TileMap.new(data["zones/district_two"]).floor,
                 "zones/district_two sits on FLOOR -2")
    # v20 T7: the descent's last step — ZONE 5 is FLOOR -3, the abyss.
    assert_equal(-3, Core::TileMap.new(data["zones/low_quay"]).floor,
                 "zones/low_quay sits on FLOOR -3")
    refute_empty Core::TileMap.new(data["zones/dungeon_1"]).enemy_spawns,
                 "DUNGEON 1 authors conservative combat"
  end
end
