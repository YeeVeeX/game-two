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
require_relative "scenes/netplay_scene"

module Harness
  SCENES = {
    "moving_square" => Scenes::MovingSquare,
    "world" => Scenes::WorldScene,
    "netplay" => Scenes::NetplayScene
  }.freeze

  class ReplayWindow < Gosu::Window
    def initialize(script_path, out_dir_override = nil)
      raw = JSON.parse(File.read(script_path), symbolize_names: true)
      w = raw.fetch(:width, 640)
      h = raw.fetch(:height, 360)
      super(w, h)
      self.caption = "game-two replay: #{raw[:scenario]}"

      scene_kwargs = { width: w, height: h, seed: raw.fetch(:seed, 0) }
      scene_kwargs[:start] = raw[:start] if raw[:start] && raw.fetch(:scenario) == "world"
      scene_kwargs[:netplay] = raw[:netplay] if raw.fetch(:scenario) == "netplay"
      @scene = SCENES.fetch(raw.fetch(:scenario)).new(**scene_kwargs)
      @input = Core::ScriptedInput.new(frames: Harness.expand_script(raw))
      @captures = raw.fetch(:captures, []).to_a
      # Video mode (quality-flywheel lane 2, 2026-08-19): VIDEO_EVERY=<n>
      # dumps every nth rendered frame into <out_dir>/video/ for ffmpeg
      # assembly (harness/make_clip.sh). Env-gated and OFF by default —
      # gate captures, manifests, and the wall stay byte-identical (the
      # wall never sets it). Frames land in a SEPARATE subdir so
      # manifest checks over the captures dir never see them.
      @video_every = ENV["VIDEO_EVERY"]&.to_i
      @video_every = nil if @video_every && @video_every < 1
      @video_count = 0
      @run_until = raw.fetch(:run_until)
      @out_dir = out_dir_override || raw.fetch(:out_dir)
      FileUtils.mkdir_p(@out_dir)
      @video_dir = File.join(@out_dir, "video")
      FileUtils.mkdir_p(@video_dir) if @video_every
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
      if @video_every && (@frame % @video_every).zero?
        vpath = File.join(@video_dir, format("v_%06d.png", @video_count))
        Harness.save_opaque(Gosu.render(width, height) { @scene.draw }, vpath)
        @video_count += 1
      end
      @frame += 1
      if @frame >= @run_until
        puts @scene.summary if @scene.respond_to?(:summary)
        puts "video frames: #{@video_count} -> #{@video_dir}" if @video_every
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
