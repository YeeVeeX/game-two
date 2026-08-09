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
require_relative "scenes/moving_square"
require_relative "scenes/world_scene"

module Harness
  SCENES = {
    "moving_square" => Scenes::MovingSquare,
    "world" => Scenes::WorldScene
  }.freeze

  def self.expand_script(raw)
    frames = Hash.new { |h, k| h[k] = [] }
    raw.fetch(:hold, {}).each do |action, ranges|
      ranges.each do |(from, to)|
        (from..to).each { |f| frames[f] << action.to_s }
      end
    end
    raw.fetch(:frames, {}).each do |frame, actions|
      frames[Integer(frame.to_s)].concat(actions)
    end
    frames
  end

  class ReplayWindow < Gosu::Window
    def initialize(script_path)
      raw = JSON.parse(File.read(script_path), symbolize_names: true)
      w = raw.fetch(:width, 640)
      h = raw.fetch(:height, 360)
      super(w, h)
      self.caption = "game-two replay: #{raw[:scenario]}"

      @scene = SCENES.fetch(raw.fetch(:scenario)).new(width: w, height: h)
      @input = Core::ScriptedInput.new(frames: Harness.expand_script(raw))
      @captures = raw.fetch(:captures, []).to_a
      @run_until = raw.fetch(:run_until)
      @out_dir = raw.fetch(:out_dir)
      FileUtils.mkdir_p(@out_dir)
      @frame = 0
    end

    def update
      @input.update(@frame)
      @scene.tick(@input)
      if @captures.include?(@frame)
        path = File.join(@out_dir, format("frame_%04d.png", @frame))
        save_opaque(Gosu.render(width, height) { @scene.draw }, path)
        puts "captured #{path}"
      end
      @frame += 1
      close if @frame >= @run_until
    end

    def draw
      @scene.draw
    end

    private

    # The window's backbuffer is opaque, but Gosu.render keeps blended alpha
    # (a translucent overlay leaves e.g. a=198 in the PNG), so viewers
    # composite the capture against their own background and misrepresent the
    # frame. Flatten alpha so captures match what the player sees.
    def save_opaque(image, path)
      blob = image.to_blob.dup
      (3...blob.bytesize).step(4) { |i| blob.setbyte(i, 255) }
      Gosu::Image.from_blob(image.width, image.height, blob).save(path)
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  script = ARGV[0] or abort "Usage: ruby -Isrc harness/replay_runner.rb <script.json>"
  Harness::ReplayWindow.new(script).show
  puts "REPLAY_DONE"
end
