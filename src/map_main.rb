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
  # counters. Passes the strict decoder (World applies it like any save).
  PROBE_FACTS = {
    "banked" => 42, "provisions" => 2, "home_zone" => "camp",
    "breached" => [["district", [42, 13]]],
    "members" => [
      { "kit" => "striker", "hp" => 80, "inscribed" => true },
      { "kit" => "blocker", "hp" => 160, "inscribed" => false },
      { "kit" => "lobber", "hp" => 60, "inscribed" => false }
    ],
    "counters" => { "boss_1_defeats" => 3, "sessions" => 5 }
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
      result = App::SaveStore.new(path: path).load(data: data)
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
      puts "MAP PROBES PASS (5/5)"
    end

    def probe(name, ok)
      abort "MAP PROBE FAIL: #{name}" unless ok
      puts "MAP PROBE ok: #{name}"
    end
  end
end

App::MapWindow.new.show
