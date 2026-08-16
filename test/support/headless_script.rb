require "json"
require "digest"
require "core/data_store"
require "core/input"
require "game/world"
require_relative "../../harness/support"
require_relative "../../harness/event_log"

# v17 digest lane: drives the REAL World through a wall script's inputs
# WITHOUT Gosu render (no window, no captures — CI-safe). The collected
# EVENT lines flow through the same Harness::EventLog + Net::EventSerial
# path the replay window uses, so the md5 here is comparable to the wall
# logs' `grep '^EVENT ' | md5sum` recipe (the banked etapa-0 instrument).
module Headless
  Result = Data.define(:world, :lines, :md5)

  def self.run_script(path, data_dir: File.expand_path("../../data", __dir__))
    raw = JSON.parse(File.read(path), symbolize_names: true)
    world = Game::World.new(Core::DataStore.new(data_dir), seed: raw.fetch(:seed, 0))
    Harness.apply_start(world, raw[:start])
    lines = []
    Harness::EventLog.attach(world) { |line| lines << line }
    input = Core::ScriptedInput.new(frames: Harness.expand_script(raw))
    raw.fetch(:run_until).times do
      input.update(world.frame)
      world.tick(input)
    end
    Result.new(world:, lines:, md5: Digest::MD5.hexdigest(lines.map { |l| "#{l}\n" }.join))
  end
end
