require "core/data_store"
require "core/strings"
require "core/binding_map"
require "core/input"
require "game/world"
require "game/telemetry"
require "net/session"
require "app/renderer"
require "app/netplay_overlay"
require "app/menu"
require "app/key_table"
require_relative "../event_log"
require_relative "../support"

# v17 Rule-2 netplay vehicle (spec Presentation spec, Codex fold #10): TWO
# real Worlds + TWO real Sessions over real loopback TCP inside the replay
# window process — the increment-6 lane, rendered. Seat-1's view draws
# through the REAL Renderer + REAL NetplayOverlay (no mocks). The window's
# scripted input IS seat 1's live source (sampled by the session once per
# executed tick — the sampling law runs for real).
#
# DETERMINISM LAW (the gate double-replays and md5-compares): now_ms is a
# PURE FUNCTION OF THE FRAME (frame * TICK_MS) — never a real clock. All
# fault injection is scripted by frame number. Port/epoch/seed are pinned
# in the script, so session_id (and the desync artifact path on the DESYNC
# screen) is byte-stable across runs.
#
# Script "netplay" keys (frame timebase unless noted):
#   port, epoch        — pinned wire identity (session_id = seed^epoch)
#   join_at            — frame the joiner constructs+connects
#   handshake_stride   — joiner updates every Nth frame until RUN (slow
#                        probes => clamped D + LINK SLOW, deterministic)
#   freeze             — [[from,to],...] frames the joiner's pump is dead
#                        (stall overlay: WAITING FOR PARTNER + ms)
#   teleports          — [{tick:, seat:, tile: [x,y]}, ...] applied to EACH
#                        world as ITS OWN tick count crosses the key — the
#                        two worlds run ~D ticks apart, so frame-keyed sim
#                        mutation would land at different sim ticks and
#                        manufacture a desync (hit live on the first run)
#   kill_seat1_at_tick — kills every body seat 1 could hold (same per-
#                        world tick law; waiting-for-body: NO BODY)
#   diverge_at_tick    — pokes the HOST world only (bank! 1) => real desync
#   sever_at           — joiner's socket hard-closed (frame), no BYE =>
#                        CONNECTION LOST on the host
#   quit_at            — host Esc (frame; clean BYE exchange, reason=quit)
#   seat2              — {hold:, frames:} input spec, SIM-TICK timebase
#                        (inputs are sampled at executed ticks, not frames)
module Harness
  module Scenes
    class NetplayScene
      TICK_MS = 16.67

      attr_reader :world

      def initialize(width:, height:, seed: 0, netplay: {})
        @data = Core::DataStore.new(File.expand_path("../../data", __dir__))
        @cfg = @data["netplay"]
        @np = netplay
        @seed = seed
        @frame = 0
        @stride = @np.fetch(:handshake_stride, 1)
        @freeze = (@np.fetch(:freeze, [])).map { |(a, b)| (a..b) }
        @teleports = @np.fetch(:teleports, [])
        @host = Net::Session.host(bind: "127.0.0.1", port: @np.fetch(:port),
                                  config: @cfg, seed:, epoch: @np.fetch(:epoch, 1))
        @seat2 = Core::ScriptedInput.new(frames: Harness.expand_script(@np.fetch(:seat2, {})))
        # E1.7 (T0 d1/b2): the FULL presentation stack through the one
        # factory — before this the scene built a bare Renderer and the
        # three net gates judged the quad fallback (the partner-seat cyan
        # halo had never been captured anywhere).
        @renderer = App::Renderer.build(@data)
        @overlay = App::NetplayOverlay.new(display: @data["display"],
                                           strings: Core::Strings.new(@data, locale: "en"),
                                           view_w: width, view_h: height)
        # J6-C: the menu at the window's exact seam (tick + route on the
        # HOST input) — the reel proves the panels AND that an open menu
        # keeps idle frames flowing (the lockstep world advances beneath).
        @menu = App::Menu.new(display: @data["display"],
                              strings: Core::Strings.new(@data, locale: "en"),
                              bindings: Core::BindingMap.load(
                                @data, key_table: App::KEY_TABLE, local: false
                              ),
                              view_w: width, view_h: height)
      end

      def tick(input)
        now = @frame * TICK_MS
        join_if_scheduled
        attach_worlds
        stage_pokes
        # J-6 seam mirrored from the window (s56 merge fold): the menu
        # ticks only over a live un-ended session (menu_active? gates
        # @world + !ended live — no handshake-screen menus), and a session
        # end FORCE-CLOSES it so the ending screen is never buried under a
        # frozen menu (J6-C banked row — the 710 capture is this law in
        # pixels). MIRROR LIMIT: the live window also gates ticking on
        # !@quitting, so during the BYE drain a real menu ignores input —
        # this scene has no quitting flag and would still tick there.
        # Inert while no script stages menu/nav rows between quit_at and
        # session end; keep it that way or add the drain guard first.
        # SECOND LIMIT (s56 merge review): tick's return is discarded — a
        # scripted QUIT-row selection silently no-ops here, where the live
        # window routes it to handle_menu → request_quit. Reels end
        # sessions via the quit_at poke, never the QUIT row.
        host_input = input
        if @world && !@host.ended?
          @menu.tick(input)
          host_input = @menu.route(input)
        end
        @host.update(now, host_input) unless @host.ended?
        @menu.close! if @host.ended?
        if @join && !@join.ended? && joiner_alive?
          @join.update(now, @seat2) unless frozen?
        end
        log_phases
        @frame += 1
      end

      def draw
        @renderer.draw(@world) if @world
        @overlay.draw(@host, @world)
        @menu.draw(session: @host, world: @world)
      end

      def summary
        lines = []
        lines << @telemetry.summary if @telemetry
        lines << @host.telemetry_line
        lines << @join.telemetry_line if @join
        lines.join("\n")
      end

      private

      def join_if_scheduled
        return unless @frame == @np.fetch(:join_at, -1)
        @join = Net::Session.join(host: "127.0.0.1", port: @np.fetch(:port), config: @cfg)
      end

      # The scene mirrors the window's attach law: build the two-seat World
      # from handshake params the moment they are known, per seat.
      def attach_worlds
        if @world.nil? && @host.params_known?
          @world = Game::World.new(@data, seed: @host.params.seed, seats: 2)
          @telemetry = Game::Telemetry.new(@world.bus, world: @world)
          Harness::EventLog.attach(@world) { |line| puts line }
          @host.attach(@world)
        end
        return unless @join && @world_j.nil? && @join.params_known?
        @world_j = Game::World.new(@data, seed: @join.params.seed, seats: 2)
        @join.attach(@world_j)
      end

      # Sim-mutating pokes are keyed by WORLD TICK and applied to each
      # world independently as its own tick count reaches the key — both
      # timelines mutate at the same sim instant, digests stay identical.
      # diverge_at_tick pokes the HOST world ONLY: that one IS the desync.
      # Wire/app pokes (sever/quit) stay frame-keyed — they are not sim
      # state. Applied-flags guard stalled frames (world.frame holds still
      # across scene frames while a session stalls).
      def stage_pokes
        { h: @world, j: @world_j }.each do |slot, w|
          next unless w
          apply_tick_pokes(slot, w)
        end
        if @world && !@diverged && @world.frame == @np.fetch(:diverge_at_tick, -1)
          @world.pack.bank!(1)
          @diverged = true
        end
        if @frame == @np.fetch(:sever_at, -1) && @join
          @join.sever!
          @severed = true
        end
        @host.quit!(@frame * TICK_MS) if @frame == @np.fetch(:quit_at, -1)
      end

      def apply_tick_pokes(slot, w)
        @applied ||= { h: {}, j: {} }
        done = @applied[slot]
        @teleports.each_with_index do |t, i|
          next if done[[:tp, i]] || w.frame != t.fetch(:tick)
          w.possessed(t.fetch(:seat))&.walker&.teleport(*t.fetch(:tile))
          done[[:tp, i]] = true
        end
        return if done[:kill] || w.frame != @np.fetch(:kill_seat1_at_tick, -1)
        killer = w.possessed(2)
        [w.pack.members.find { |m| !w.controlled?(m) && !m.dead? },
         w.possessed(1)].compact.each do |b|
          b.take_hit(damage: b.hp, attacker: killer) until b.dead?
        end
        done[:kill] = true
      end

      def joiner_alive? = !@severed

      # The stride throttles the joiner only during the handshake (slow
      # measured probes); freeze windows kill its pump mid-run (stall).
      def frozen?
        return true if @freeze.any? { |r| r.cover?(@frame) }
        return false if @join.running? || @join.ended?
        ((@frame - @np.fetch(:join_at)) % @stride) != 0
      end

      # Deterministic phase trace: capture scripts aim at these lines the
      # way world scripts aim at EVENT lines.
      def log_phases
        state = [@host.phase, @host.reason, @join&.phase, @join&.reason,
                 @host.stall_warning_ms ? 1 : 0,
                 @world ? @world.gate_wait : nil,
                 @world && @host.running? ? @world.possessed(1).nil? : false]
        return if state == @last_state
        @last_state = state
        puts "NETPLAY frame=#{@frame} h=#{@host.phase}/#{@host.reason} " \
             "j=#{@join ? "#{@join.phase}/#{@join.reason}" : '-'} tick=#{@host.ticks} " \
             "stall=#{state[4]} gate_wait=#{state[5].inspect} no_body=#{state[6]}"
      end
    end
  end
end
