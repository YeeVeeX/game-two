# v18 god-view v0 (spec decision 13): render the offline map artifact in a
# real GL window (Gosu.render law — never headless), then close.
#
# Usage: ruby -Isrc src/map_main.rb [SAVE=path] [OUT=dir] [PROBES=1]
#   SAVE=   save file to read (default: data/persistence.json save_path;
#           missing file = fresh world, the honest zero state)
#   OUT=    output directory (default captures/map)
#   PROBES=1  render the STAGED probe facts instead of the save and run the
#           deterministic landmark asserts (breached≠sealed cell, home
#           marker, header presence) — the map gate = this + the critique
#           (`python harness/vision_critic.py --verdict <out> --checks
#           harness/map_checks.json`). No replay half: there is no sim.
require "json"
require "gosu"
require "fileutils"
require "core/data_store"
require "core/strings"
require "game/world"
require "app/save_store"
require "app/map_artifact"

module App
  # Staged facts for the probe artifact: every landmark surface exists —
  # non-default home (camp), one breached way beside sealed ones, nonzero
  # counters, and (T4) the pilot well DRAINED so the water swap and the
  # opened hole both render. Passes the strict decoder (World applies it
  # like any save; zone_7's seal makes the tuple legal — D11). Schema 3
  # (v22 T1): the staged character is keyed "bot-1" = the harness default
  # host id, so the World seats it (a foreign id would seat a NEW level-1
  # character and the deep gates would draw sealed).
  PROBE_FACTS = {
    "banked" => 42, "provisions" => 2,
    "breached" => [["district", [42, 13]], ["zone_7", [33, 14]]],
    "counters" => { "boss_1_defeats" => 3, "sessions" => 5 },
    "characters" => {
      "bot-1" => {
        # Level 6 clears the s68 deep gates: the staged-open hole [33,14]
        # composes sealed+requires_level as independent AND legs, so the
        # breach alone no longer draws it gold (way_locked? reads BOTH).
        "level" => 6, "xp" => 0, "xp_debt" => 0, "insurance" => 0,
        "home_zone" => "camp", "form" => "blocker",
        "forms" => {
          "striker" => { "hp" => 80, "inscribed" => true },
          "blocker" => { "hp" => 160, "inscribed" => false },
          "lobber" => { "hp" => 60, "inscribed" => false }
        },
        "bag" => [], "equipment" => {}, "attributes" => {}, "bank_items" => []
      }
    }
  }.freeze

  class MapWindow < Gosu::Window
    def initialize
      super(320, 180)
      self.caption = "game-two map artifact"
      @done = false
    end

    def update
      return close if @done
      @done = true
      data = Core::DataStore.new(File.expand_path("../data", __dir__))
      facts = resolve_facts(data)
      world = Game::World.new(data, seed: 0, save: facts)
      artifact = App::MapArtifact.new(data, strings: Core::Strings.new(data, locale: "en"))
      out_dir = ENV.fetch("OUT", "captures/map")
      FileUtils.mkdir_p(out_dir)
      img = artifact.compose(world)
      path = File.join(out_dir, artifact.filename(world))
      img.save(path)
      puts "MAP saved #{path} (#{img.width}x#{img.height})"
      run_probes(world, artifact, img) if ENV["PROBES"] == "1"
    end

    def draw; end

    private

    def resolve_facts(data)
      return Marshal.load(Marshal.dump(PROBE_FACTS)) if ENV["PROBES"] == "1"
      path = ENV.fetch("SAVE") { data["persistence"][:save_path] }
      return nil unless File.exist?(path)
      # The offline map reads through the same loader the game boots with:
      # a schema-2 file migrates in memory keyed by THIS machine's player
      # id (read-only here — the backup + v3 write only happen in a session).
      # Read-only surface: it never CREATES the identity file (fresh-eyes
      # s136) — the machine's id when one exists, else a harness id (the id
      # only keys a schema-2 migration in memory; nothing here renders it).
      require "app/player_file"
      player_id = File.exist?(App::PlayerFile::DEFAULT_PATH) ? App::PlayerFile.load.player_id : "bot-map"
      result = App::SaveStore.new(path: path).load(data: data, player_id: player_id)
      case result
      when App::SaveStore::Loaded
        puts "MAP loaded save digest=#{result.digest} source=#{path}"
        result.facts
      when App::SaveStore::Refused
        abort "MAP refused: #{result.refusal}"
      else
        nil
      end
    end

    # Deterministic landmark asserts (decision 13): pixel probes over the
    # composed image bytes — the vision critique judges everything else.
    def run_probes(world, artifact, img)
      blob = img.to_blob # RGBA, row-major
      w = img.width
      px = ->(x, y) { blob[(y * w + x) * 4, 3].bytes }
      l = artifact.layout(world)
      district = l[:panels].find { |p| p[:name] == "district" }
      camp = l[:panels].find { |p| p[:name] == "camp" }
      nest = l[:panels].find { |p| p[:name] == "nest" }

      # 1. A breached way differs from a sealed one (same zone: district's
      # [42,13] is OPEN in the probe facts; find a SEALED way anywhere).
      ox, oy = district[:origin]
      open_rgb = px.call(ox + 42 * App::MapArtifact::SCALE + 2,
                         oy + 13 * App::MapArtifact::SCALE + 2)
      sealed = artifact.seal_stamps(world).find { |s| s[:text] == "SEALED" }
      sp = l[:panels].find { |p| p[:name] == sealed[:zone] }
      sx, sy = sp[:origin]
      sealed_rgb = px.call(sx + sealed[:at][0] * App::MapArtifact::SCALE + 2,
                           sy + sealed[:at][1] * App::MapArtifact::SCALE + 2)
      probe "breached cell differs from sealed", open_rgb != sealed_rgb
      probe "breached cell is the zone's gate gold",
            open_rgb == world.zone_maps.fetch("district").palette[:transition]

      # 2. The home marker frames the home zone's panel (camp in the probe
      # facts) and NOT another panel.
      hx, hy = camp[:origin]
      probe "home marker present on home panel",
            px.call(hx - 1, hy - 1) == App::MapArtifact::HOME_MARK
      nx, ny = nest[:origin]
      probe "no home marker on a non-home panel",
            px.call(nx - 1, ny - 1) != App::MapArtifact::HOME_MARK

      # 3. The header strip carries text (some non-background pixel in the
      # header band).
      band = (0...App::MapArtifact::HEADER_H).any? do |y|
        (0...[w, 400].min).any? { |x| px.call(x, y) != App::MapArtifact::CHROME_BG }
      end
      probe "header strip present", band

      # 4. T4 pilot zones: ZONE 7's drained well (staged breach) shows the
      # dry ring + the opened hole; DUNGEON 1's panel carries its own
      # palette (not an empty slab — the T3 god-view catch, re-pinned).
      z7 = l[:panels].find { |p| p[:name] == "zone_7" }
      zx, zy = z7[:origin]
      z7pal = world.zone_maps.fetch("zone_7").palette
      ring = px.call(zx + 32 * App::MapArtifact::SCALE + 2,
                     zy + 14 * App::MapArtifact::SCALE + 2)
      probe "drained well ring shows the dry look", ring == z7pal[:water_drained]
      probe "dry ring is not the water look", ring != z7pal[:water]
      hole = px.call(zx + 33 * App::MapArtifact::SCALE + 2,
                     zy + 14 * App::MapArtifact::SCALE + 2)
      probe "drained hole reads gate-gold (walkable law)", hole == z7pal[:transition]
      grass = px.call(zx + 5 * App::MapArtifact::SCALE + 2,
                      zy + 5 * App::MapArtifact::SCALE + 2)
      probe "zone_7 meadow reads a grass family tone",
            [z7pal[:grass], z7pal[:grass_b], z7pal[:grass_c]].include?(grass)
      # MUNDO VIVO FASE 6.1 (the swap): DUNGEON 1 is the MEDUSA LOWER
      # geometry — the abyss void is the second wall class, the serpent head
      # carries the floor, the rope back sits beside the arrival [9,8] and
      # the frontier rope moved to the head's north rim [29,7].
      d1 = l[:panels].find { |p| p[:name] == "dungeon_1" }
      dx, dy = d1[:origin]
      d1pal = world.zone_maps.fetch("dungeon_1").palette
      probe "dungeon_1 abyss void reads the second wall class",
            px.call(dx + 2 * App::MapArtifact::SCALE + 2,
                    dy + 2 * App::MapArtifact::SCALE + 2) == d1pal[:wall_inner]
      probe "dungeon_1 serpent head carries its own floor",
            px.call(dx + 12 * App::MapArtifact::SCALE + 2,
                    dy + 9 * App::MapArtifact::SCALE + 2) == d1pal[:floor]
      probe "dungeon_1 rope tile reads gate-gold",
            px.call(dx + 9 * App::MapArtifact::SCALE + 2,
                    dy + 8 * App::MapArtifact::SCALE + 2) == d1pal[:transition]
      # 5. s70 wire-in: the frontier way is LEVEL-GATED at the staged level
      # (6 < 8 draws the seal slab, not gold) while zone_8's free return
      # reads gate-gold — both directions of the new edge render honestly.
      slab = App::Renderer::SEAL_SLAB
      probe "dungeon_1 frontier way reads level-locked at staged level 6",
            px.call(dx + 29 * App::MapArtifact::SCALE + 2,
                    dy + 7 * App::MapArtifact::SCALE + 2) == [slab.red, slab.green, slab.blue]
      z8 = l[:panels].find { |p| p[:name] == "zone_8" }
      ex, ey = z8[:origin]
      z8pal = world.zone_maps.fetch("zone_8").palette
      probe "zone_8 free return reads gate-gold (walkable law)",
            px.call(ex + 63 * App::MapArtifact::SCALE + 2,
                    ey + 19 * App::MapArtifact::SCALE + 2) == z8pal[:transition]
      # 6. v20 T6b floor -2: the retheme's own landmarks — the coral margin
      # renders the SECOND wall class (wall_inner, never :wall), the channel
      # keeps the water look, and the save-pinned door [42,13] reads SEALED
      # under probe facts (no district_two breach staged — the live chain's
      # tuple stays honest).
      d2 = l[:panels].find { |p| p[:name] == "district_two" }
      d2x, d2y = d2[:origin]
      d2pal = world.zone_maps.fetch("district_two").palette
      probe "district_two coral margin reads the second wall class",
            px.call(d2x + 43 * App::MapArtifact::SCALE + 2,
                    d2y + 13 * App::MapArtifact::SCALE + 2) == d2pal[:wall_inner]
      probe "district_two channel reads the water look",
            px.call(d2x + 43 * App::MapArtifact::SCALE + 2,
                    d2y + 17 * App::MapArtifact::SCALE + 2) == d2pal[:water]
      probe "district_two save-pinned door reads sealed",
            px.call(d2x + 42 * App::MapArtifact::SCALE + 2,
                    d2y + 13 * App::MapArtifact::SCALE + 2) == [slab.red, slab.green, slab.blue]
      # 7. MUNDO VIVO FASE 6.1 floor -3 = MUSGO A ("salão selado"): the
      # moss carpets the walkable floor (its own typed ref, brighter than
      # the loam floor), the vault's stone walls render the :wall palette,
      # BOSS 1's post sits inside the vault, and the south door reads OPEN
      # gate-gold under the staged boss_1_defeats=3 (requires_defeats 1
      # satisfied - the fact-gate renders honestly).
      lq = l[:panels].find { |p| p[:name] == "low_quay" }
      lqx, lqy = lq[:origin]
      lqpal = world.zone_maps.fetch("low_quay").palette
      probe "low_quay moss carpet reads the moss ref (entry hall)",
            px.call(lqx + 7 * App::MapArtifact::SCALE + 2,
                    lqy + 18 * App::MapArtifact::SCALE + 2) == lqpal[:moss]
      probe "low_quay vault wall reads the wall palette",
            px.call(lqx + 33 * App::MapArtifact::SCALE + 2,
                    lqy + 18 * App::MapArtifact::SCALE + 2) == lqpal[:wall]
      probe "low_quay vault interior (BOSS 1's post) is moss floor",
            px.call(lqx + 41 * App::MapArtifact::SCALE + 2,
                    lqy + 18 * App::MapArtifact::SCALE + 2) == lqpal[:moss]
      probe "low_quay south door reads gate-gold at staged defeats",
            px.call(lqx + 24 * App::MapArtifact::SCALE + 2,
                    lqy + 34 * App::MapArtifact::SCALE + 2) == lqpal[:transition]
      puts "MAP PROBES PASS (21/21)"
    end

    def probe(name, ok)
      abort "MAP PROBE FAIL: #{name}" unless ok
      puts "MAP PROBE ok: #{name}"
    end
  end
end

App::MapWindow.new.show
