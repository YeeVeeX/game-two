# Rule 2 harness: deterministic input replay + frame capture.
#
# Usage: ruby -Isrc harness/replay_runner.rb harness/scripts/<name>.json
#
# Script format:
#   {
#     "scenario": "moving_square",
#     "width": 640, "height": 360,
#     "hold":     { "right": [[0, 59]] },        // action held over frame ranges
#     "frames":   { "60": ["attack"] },           // per-frame actions (merged with hold)
#     "captures": [0, 30, 60],                    // sim frames to save as PNG
#     "run_until": 61,                            // close after this many sim frames
#     "out_dir":  "captures/moving_square"
#   }
#
# Captures happen inside update() right after the sim tick — verified live on
# this machine (Gosu.render works there; the GL context is current).
require "json"
require "gosu"
require "fileutils"
require "core/input"
require_relative "support"
require_relative "scenes/moving_square"
require_relative "scenes/world_scene"

module Harness
  SCENES = {
    "moving_square" => Scenes::MovingSquare,
    "world" => Scenes::WorldScene
  }.freeze

  class ReplayWindow < Gosu::Window
    def initialize(script_path, out_dir_override = nil)
      raw = JSON.parse(File.read(script_path), symbolize_names: true)
      w = raw.fetch(:width, 640)
      h = raw.fetch(:height, 360)
      super(w, h)
      self.caption = "game-two replay: #{raw[:scenario]}"

      @scene = SCENES.fetch(raw.fetch(:scenario)).new(width: w, height: h, seed: raw.fetch(:seed, 0))
      @input = Core::ScriptedInput.new(frames: Harness.expand_script(raw))
      @captures = raw.fetch(:captures, []).to_a
      @run_until = raw.fetch(:run_until)
      @out_dir = out_dir_override || raw.fetch(:out_dir)
      FileUtils.mkdir_p(@out_dir)
      @frame = 0
    end

    def update
      @input.update(@frame)
      @scene.tick(@input)
      if @captures.include?(@frame)
        path = File.join(@out_dir, format("frame_%04d.png", @frame))
        Harness.save_opaque(Gosu.render(width, height) { @scene.draw }, path)
        puts "captured #{path}"
      end
      @frame += 1
      if @frame >= @run_until
        puts @scene.summary if @scene.respond_to?(:summary)
        close
      end
    end

    def draw
      @scene.draw
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  script = ARGV[0] or abort "Usage: ruby -Isrc harness/replay_runner.rb <script.json> [out_dir]"
  Harness::ReplayWindow.new(script, ARGV[1]).show
  puts "REPLAY_DONE"
end
