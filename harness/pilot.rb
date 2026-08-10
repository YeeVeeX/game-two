# Pilot mode: a file-driven interactive session against the REAL sim +
# renderer in a real Gosu window. The pilot (Claude) appends command lines
# to the inbox; every response streams to the log; idle = frozen sim;
# `export` turns the whole session into a standard replay script.
#
# Usage:  rake pilot [NAME=session] [SEED=0]
#   inbox: tmp/pilot/<NAME>/inbox.txt   — APPEND-ONLY, one command per line:
#          printf 'cmd\n' >> tmp/pilot/<NAME>/inbox.txt
#          (never rewrite the file with an editor/Write tool — the reader
#          tracks a byte offset; a rewrite triggers a truncation reset)
#   log:   tmp/pilot/<NAME>/log.txt     — read/grep this for all output
#
# Commands: hold <a[,a]> <n> · press <a[,a]> · wait <n> · goto <tx> <ty>
#   [guard=N] · capture [label] · state · dump <name> · speed <1..60> ·
#   export [name] · reset [seed] · quit
#
# This file is a THIN interpreter: every decision beyond Gosu calls lives
# in harness/pilot_session.rb, under tests.
require "json"
require "gosu"
require "fileutils"
require "core/input"
require_relative "support"
require_relative "pilot_session"
require_relative "scenes/world_scene"

module Harness
  module Pilot
    class PilotWindow < Gosu::Window
      def initialize(name:, seed:)
        @name = name
        @seed = seed
        @dir = File.join("tmp", "pilot", name)
        FileUtils.mkdir_p(@dir)
        FileUtils.mkdir_p(capture_dir)

        # Own the log: everything any layer puts/warns lands in log.txt,
        # flushed per line — shell-agnostic, no redirect needed. Assign the
        # globals rather than reopen: IO#reopen takes an EXCLUSIVE handle on
        # mingw Ruby, making the log unreadable while the window lives.
        log = File.open(File.join(@dir, "log.txt"), "a")
        log.sync = true
        $stdout = log
        $stderr = log

        display = JSON.parse(File.read("data/display.json"), symbolize_names: true)
        @width = display[:view_width]
        @height = display[:view_height]
        super(@width, @height)
        self.caption = "game-two pilot: #{name}"

        inbox_path = File.join(@dir, "inbox.txt")
        File.open(inbox_path, "ab") {} # ensure it exists for appends
        @inbox = Inbox.new(inbox_path)
        @queue = []
        @speed = 10
        boot_session
        puts "READY name=#{@name} seed=#{@seed} frame=0"
      end

      def update
        poll_inbox
        run_current_command
      rescue StandardError => e
        handle_fatal(e)
      end

      def draw
        @scene.draw
      end

      private

      def capture_dir = File.join("captures", "pilot", @name)
      def world = @scene.world

      def boot_session(seed: nil)
        @seed = seed if seed
        @scene = Scenes::WorldScene.new(width: @width, height: @height, seed: @seed)
        @input = PilotInput.new
        @recorder = Recorder.new
        @current = nil
      end

      def poll_inbox
        result = @inbox.poll
        puts "ERR inbox truncated — offset reset, re-reading from 0" if result[:truncated]
        result[:lines].each do |line|
          parsed = Parser.parse(line)
          next unless parsed # blank line
          if parsed[:err]
            puts "ERR #{parsed[:err]} (line: #{line.inspect})"
          else
            @queue << parsed.merge(line:)
          end
        end
      end

      # ONE command in flight; sim-consuming commands advance <= @speed
      # ticks per update so the Windows message pump keeps breathing.
      # Instant commands (state/dump/...) resolve immediately, one per
      # update, in FIFO order. Idle (queue empty) = frozen sim.
      def run_current_command
        @current ||= @queue.shift
        return unless @current
        done = execute(@current)
        @current = nil if done
      end

      def execute(cmd)
        case cmd[:cmd]
        when :hold then run_hold(cmd)
        when :goto then run_goto(cmd)
        when :capture then run_capture(cmd)
        when :state then puts "STATE #{JSON.generate(Pilot.state_hash(world))}"; true
        when :dump then run_dump(cmd)
        when :speed then @speed = cmd[:value]; ack(cmd); true
        when :export then run_export(cmd)
        when :reset then run_reset(cmd)
        when :quit then ack(cmd); close!; true
        end
      end

      def run_hold(cmd)
        cmd[:left] ||= cmd[:frames]
        ticks = [cmd[:left], @speed].min
        ticks.times { Pilot.advance(world, @input, @recorder, cmd[:actions]) }
        cmd[:left] -= ticks
        return false if cmd[:left].positive?
        ack(cmd)
        true
      end

      def run_goto(cmd)
        cmd[:engine] ||= GotoEngine.new(world, cmd[:tile], guard: cmd[:guard])
        @speed.times do
          result = cmd[:engine].step
          case result[:status]
          when :walking
            Pilot.advance(world, @input, @recorder, result[:actions])
          when :arrived
            puts "GOTO_OK tile=#{result[:tile].inspect} frame=#{world.frame}"
            return true
          else
            puts "GOTO_FAILED reason=#{result[:status]} tile=#{result[:tile].inspect}"
            return true
          end
        end
        false
      end

      def run_capture(cmd)
        replay_frame = @recorder.note_capture
        unless replay_frame
          puts "ERR capture at frame 0 has no replay representation — wait 1 first"
          return true
        end
        suffix = cmd[:label] ? "_#{cmd[:label]}" : ""
        path = File.join(capture_dir, format("frame_%04d%s.png", replay_frame, suffix))
        Harness.save_opaque(Gosu.render(@width, @height) { @scene.draw }, path)
        puts "CAPTURED #{path} frame=#{world.frame}"
        true
      end

      def run_dump(cmd)
        creature = (world.pack.members + world.humans).find { |c| c.name == cmd[:name] }
        if creature
          puts "DUMP #{JSON.generate(Pilot.dump_hash(creature))}"
        else
          puts "ERR no creature named '#{cmd[:name]}' in #{world.zone_name}"
        end
        true
      end

      def run_export(cmd)
        name = cmd[:name] || "session"
        path = File.join(@dir, "#{name}.json")
        script = @recorder.to_script(seed: @seed, width: @width, height: @height,
                                     out_dir: File.join("captures", "pilot", "#{@name}_replay"))
        File.write(path, JSON.pretty_generate(script))
        puts "EXPORTED #{path} run_until=#{script[:run_until]}"
        true
      end

      def run_reset(cmd)
        boot_session(seed: cmd[:seed])
        puts "READY name=#{@name} seed=#{@seed} frame=0"
        true
      end

      def ack(cmd)
        puts "ACK #{cmd[:line]} frame=#{world.frame}"
      end

      # The input history is most valuable AT the crash: export it before
      # dying so the session replays up to the failing tick.
      def handle_fatal(error)
        puts "FATAL #{error.class}: #{error.message}"
        error.backtrace.first(15).each { |l| puts "  #{l}" }
        crash = @recorder.to_script(seed: @seed, width: @width, height: @height,
                                    out_dir: File.join("captures", "pilot", "#{@name}_crash"))
        File.write(File.join(@dir, "crash.json"), JSON.pretty_generate(crash))
        puts "EXPORTED #{File.join(@dir, 'crash.json')} run_until=#{crash[:run_until]}"
        close!
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  Harness::Pilot::PilotWindow.new(
    name: ENV.fetch("NAME", "session"),
    seed: Integer(ENV.fetch("SEED", "0"), 10)
  ).show
end
