# Pilot mode's pure core: everything decidable without a window lives here,
# under plain minitest. harness/pilot.rb is only the Gosu-facing shell.
#
# PURITY RULE: no gosu require, no Gosu constant. Tests drive these classes
# against real files and a real Game::World, headless.
require "json"
require "core/input"
require "game/controllers"
require "game/flow_field"

module Harness
  module Pilot
    # The one action vocabulary: whatever the possessed controller accepts,
    # plus the world-level swap. Required from the game, never duplicated.
    ACTIONS = (Game::PossessedController::ACTIONS + [:swap]).freeze

    # A parsed command is a plain Hash{cmd:}; errors are {err: "message"}.
    # The window shell never sees a raw token stream.
    module Parser
      MAX_FRAMES = 100_000 # ~28 min of sim; beyond this a typo, not a plan
      SPEED_RANGE = (1..60).freeze
      NAME_SAFE = /\A[A-Za-z0-9_-]+\z/

      module_function

      def parse(line)
        tokens = line.split
        return nil if tokens.empty?
        cmd = tokens.shift
        case cmd
        when "hold" then parse_hold(tokens)
        when "press" then parse_press(tokens)
        when "wait" then parse_wait(tokens)
        when "goto" then parse_goto(tokens)
        when "capture" then parse_capture(tokens)
        when "state" then bare(:state, tokens)
        when "dump" then parse_dump(tokens)
        when "speed" then parse_speed(tokens)
        when "export" then parse_export(tokens)
        when "reset" then parse_reset(tokens)
        when "quit" then bare(:quit, tokens)
        else err("unknown command '#{cmd}'")
        end
      end

      def parse_hold(tokens)
        return err("usage: hold <action[,action]> <frames>") unless tokens.length == 2
        actions = parse_actions(tokens[0])
        return actions if actions.is_a?(Hash)
        frames = parse_frames(tokens[1])
        return frames if frames.is_a?(Hash)
        { cmd: :hold, actions:, frames: }
      end

      def parse_press(tokens)
        return err("usage: press <action[,action]>") unless tokens.length == 1
        actions = parse_actions(tokens[0])
        return actions if actions.is_a?(Hash)
        { cmd: :hold, actions:, frames: 1 }
      end

      def parse_wait(tokens)
        return err("usage: wait <frames>") unless tokens.length == 1
        frames = parse_frames(tokens[0])
        return frames if frames.is_a?(Hash)
        { cmd: :hold, actions: [], frames: }
      end

      def parse_goto(tokens)
        guard = 3000
        if tokens.length == 3 && tokens[2] =~ /\Aguard=(\d+)\z/
          guard = Integer(Regexp.last_match(1))
          tokens = tokens[0, 2]
        end
        return err("usage: goto <tx> <ty> [guard=N]") unless tokens.length == 2
        tile = tokens.map { |t| non_negative(t) }
        return err("goto coordinates must be non-negative integers") if tile.any?(&:nil?)
        { cmd: :goto, tile:, guard: }
      end

      def parse_capture(tokens)
        return err("usage: capture [label]") if tokens.length > 1
        label = tokens[0]
        return err("capture label must match #{NAME_SAFE.source}") if label && label !~ NAME_SAFE
        { cmd: :capture, label: }
      end

      def parse_dump(tokens)
        return err("usage: dump <creature-name>") unless tokens.length == 1
        { cmd: :dump, name: tokens[0] }
      end

      def parse_speed(tokens)
        return err("usage: speed <1..60>") unless tokens.length == 1
        value = non_negative(tokens[0])
        return err("speed must be in #{SPEED_RANGE}") unless value && SPEED_RANGE.cover?(value)
        { cmd: :speed, value: }
      end

      def parse_export(tokens)
        return err("usage: export [name]") if tokens.length > 1
        name = tokens[0]
        return err("export name must match #{NAME_SAFE.source}") if name && name !~ NAME_SAFE
        { cmd: :export, name: }
      end

      def parse_reset(tokens)
        return err("usage: reset [seed]") if tokens.length > 1
        seed = nil
        if tokens[0]
          seed = non_negative(tokens[0])
          return err("seed must be a non-negative integer") unless seed
        end
        { cmd: :reset, seed: }
      end

      def bare(cmd, tokens)
        tokens.empty? ? { cmd: } : err("#{cmd} takes no arguments")
      end

      def parse_actions(token)
        actions = token.split(",").map(&:to_sym).uniq
        unknown = actions - ACTIONS
        return err("unknown action(s): #{unknown.join(', ')}") unless unknown.empty?
        return err("no actions given") if actions.empty?
        actions
      end

      def parse_frames(token)
        frames = non_negative(token)
        return err("frames must be 1..#{MAX_FRAMES}") unless frames&.between?(1, MAX_FRAMES)
        frames
      end

      def non_negative(token)
        Integer(token, 10)
      rescue ArgumentError, TypeError
        nil
      else
        Integer(token, 10).negative? ? nil : Integer(token, 10)
      end

      def err(msg) = { err: msg }
    end

    # Tail-reads the inbox file. Binary mode + pread keep the reader from
    # ever moving the writer's append position; only complete \n-terminated
    # lines are consumed (a partial write waits for its newline). A file
    # that SHRANK was rewritten, not appended — reset and tell the caller.
    class Inbox
      def initialize(path)
        @path = path
        @offset = 0
      end

      def poll
        size = File.size(@path)
        truncated = size < @offset
        @offset = 0 if truncated
        return { lines: [], truncated: } if size == @offset
        chunk = File.open(@path, "rb") { |f| f.pread(size - @offset, @offset) }
        last_newline = chunk.rindex("\n")
        return { lines: [], truncated: } unless last_newline
        @offset += last_newline + 1
        lines = chunk[0..last_newline].split("\n").map { |l| l.delete("\r") }
        { lines:, truncated: }
      rescue Errno::ENOENT
        { lines: [], truncated: false }
      end
    end

    # Records what was actually fed to the sim, one entry per tick, and
    # exports the standard replay-script shape. Hold ranges are the ONLY
    # input representation (singletons as [f,f]) — one form, exact
    # round-trip through Harness.expand_script.
    class Recorder
      def initialize
        @frames = [] # index = sim frame, value = array of action symbols
        @captures = []
      end

      def record_frame(actions)
        @frames << actions.dup
      end

      def frame_count = @frames.length

      # Registers a capture taken at the CURRENT sim frame. replay_runner
      # captures AFTER the tick that consumed input frame N, so a pilot
      # capture at world.frame K replays as capture frame K-1. At K=0
      # (nothing ticked yet) there is no replay representation: refuse.
      def note_capture
        return nil if @frames.empty?
        frame = @frames.length - 1
        @captures << frame unless @captures.include?(frame)
        frame
      end

      def to_script(seed:, width:, height:, out_dir:)
        {
          scenario: "world",
          seed:, width:, height:, out_dir:,
          hold: hold_ranges,
          captures: @captures.sort,
          run_until: @frames.length
        }
      end

      private

      def hold_ranges
        ranges = Hash.new { |h, k| h[k] = [] }
        ACTIONS.each do |action|
          run_start = nil
          @frames.each_with_index do |actions, f|
            held = actions.include?(action)
            run_start ||= f if held
            if run_start && (!held || f == @frames.length - 1)
              run_end = held ? f : f - 1
              ranges[action] << [run_start, run_end]
              run_start = nil
            end
          end
        end
        ranges
      end
    end

    # The live input source: same duck as Core::ScriptedInput (update/down?)
    # but set imperatively by the command loop each tick.
    class PilotInput
      def initialize = @current = []

      def set(actions)
        @current = actions
      end

      def update(_frame) = nil

      def down?(action) = @current.include?(action)
    end

    # --- state serializers (world -> plain JSON-able hashes) ---------------

    module_function

    def state_hash(world)
      p = world.possessed
      {
        frame: world.frame,
        zone: world.zone_name,
        state: world.states.current,
        possessed: { name: p.name, kit: p.kit_name, tile: p.tile,
                     hp: p.hp, carried: p.carried },
        banked: world.pack.banked,
        pack: world.pack.members.map { |m| creature_brief(m) },
        humans: world.humans.map { |h| creature_brief(h) },
        drops: world.drops.map { |d| { tile: d[:tile], amount: d[:amount],
                                       frames_left: d[:frames_left] } },
        mark: world.marked_target&.name
      }
    end

    def creature_brief(c)
      { name: c.name, kit: c.kit_name, tile: c.tile, hp: c.hp, dead: c.dead? }
    end

    def dump_hash(creature)
      c = creature
      {
        name: c.name, kit: c.kit_name, faction: c.faction,
        tile: c.tile, hp: c.hp, max_hp: c.max_hp, facing: c.facing,
        moving: c.moving?, attack_state: c.attack_state,
        current_action: c.current_action, stagger: c.stagger,
        dodge_cooldown: c.dodge_cooldown, exhaust_ready: c.exhaust_ready?,
        special_ready: c.special_ready?, iframes: c.iframes?,
        carried: c.carried, reserved_tile: c.reserved_tile, dead: c.dead?
      }
    end

    # Walks the possessed creature to a destination tile by synthesizing
    # per-tick direction holds — the same inputs a hand would produce, so
    # a recorded goto replays like any other hold. One #step per call:
    # the window shell owns pacing; this owns policy.
    #
    # Abort reasons (checked in this order, all snapshot-based):
    #   :unreachable         dest not passable / walled off (fail-fast)
    #   :zone_changed        a gate fired mid-walk
    #   :possession_changed  forced or voluntary swap (identity, not name)
    #   :pack_wiped          sim entered the respawn veil
    #   :guard               tick budget exhausted (livelock bound)
    class GotoEngine
      def initialize(world, dest, guard:)
        @world = world
        @dest = dest
        @guard = guard
        @ticks = 0
        @zone = world.zone_name
        @body = world.possessed
        @field = Game::FlowField.new(world.map)
        @field.recompute!(dest)
        @unreachable = !reachable_from?(@body.tile)
      end

      # Returns {status:, actions:} — :walking means feed actions and tick;
      # anything else is terminal. Terminal results carry tile: (reached).
      def step
        return terminal(:unreachable) if @unreachable
        return terminal(:zone_changed) if @world.zone_name != @zone
        return terminal(:possession_changed) unless @world.possessed.equal?(@body)
        return terminal(:pack_wiped) if @world.states.current == :nest_respawn
        return terminal(:arrived) if @body.tile == @dest && !@body.walker.moving?
        return terminal(:guard) if @ticks >= @guard
        @ticks += 1
        # Mid-tween or hitstop: hold nothing, let the sim settle. A nil
        # downhill while body-blocked is the same wait — bodies move,
        # the guard bounds the worst case.
        return { status: :walking, actions: [] } if @body.walker.moving?
        dir = @field.downhill_from(*@body.tile, blocked: @world.blocked_for(@body))
        return { status: :walking, actions: [] } unless dir
        { status: :walking, actions: direction_actions(dir) }
      end

      private

      def reachable_from?(tile)
        @field.distance(*tile) != Game::FlowField::UNREACHED
      end

      def terminal(status)
        { status:, tile: @body.tile }
      end

      def direction_actions(dir)
        actions = []
        actions << (dir[0].positive? ? :right : :left) unless dir[0].zero?
        actions << (dir[1].positive? ? :down : :up) unless dir[1].zero?
        actions
      end
    end
  end
end
