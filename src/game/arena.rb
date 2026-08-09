require "core/event_bus"
require "core/state_stack"
require "game/player"
require "game/enemy"
require "game/feel"

module Game
  # The slice's whole sim: one room, one player, one husk. Pure and
  # deterministic — same input script in, same state out. Rendering lives in
  # Game::Renderer; this class never touches Gosu.
  class Arena
    EVENTS = %i[
      attack_started attack_hit damage_dealt entity_died
      player_hit player_died player_respawned player_dodged
      enemy_telegraph
    ].freeze

    TRANSITIONS = { arena: %i[death], death: %i[arena] }.freeze

    WIDTH = 960
    HEIGHT = 540
    WALL = 24

    attr_reader :bus, :player, :enemy, :feel, :states, :frame

    def initialize(data)
      @data = data
      @bus = Core::EventBus.new.register(*EVENTS)
      @states = Core::StateStack.new(initial: :arena, transitions: TRANSITIONS)
      @feel = Feel.new(@data["balance/combat"][:feel])
      @frame = 0
      @respawn_timer = 0
      @enemy_respawn_timer = 0
      spawn_player
      spawn_enemy
      wire_events
    end

    def bounds = [WALL, WALL, WIDTH - WALL, HEIGHT - WALL]

    def tick(input)
      if @feel.hitstop?
        @feel.tick
        @bus.process
        @frame += 1
        return
      end

      case @states.current
      when :arena
        @player.tick(input, bounds: bounds)
        tick_enemy
        resolve_player_attack
      when :death
        @respawn_timer -= 1
        if @respawn_timer <= 0
          @states.transition_to(:arena)
          @player.respawn(x: WIDTH / 4 - Player::SIZE / 2, y: HEIGHT / 2 - Player::SIZE / 2)
        end
      end

      @feel.tick
      @bus.process
      @frame += 1
    end

    private

    def spawn_player
      stats = @data["balance/combat"][:player]
      @player = Player.new(bus: @bus, stats:, x: WIDTH / 4 - Player::SIZE / 2, y: HEIGHT / 2 - Player::SIZE / 2)
    end

    def spawn_enemy
      stats = @data["balance/combat"][:enemies][:husk]
      @enemy = Enemy.new(bus: @bus, stats:, x: WIDTH * 3 / 4 - Enemy::SIZE / 2, y: HEIGHT / 2 - Enemy::SIZE / 2)
    end

    def tick_enemy
      if @enemy.dead?
        @enemy_respawn_timer -= 1
        spawn_enemy if @enemy_respawn_timer <= 0
      else
        @enemy.tick(player: @player, bounds: bounds)
      end
    end

    def resolve_player_attack
      return unless @player.attack_can_hit? && !@enemy.dead?
      return unless overlap?(@player.attack_hitbox, @enemy.hitbox)

      @player.attack_landed!
      px, py = @player.center
      @enemy.take_hit(
        damage: @data["balance/combat"][:player][:attack][:damage],
        knockback: @data["balance/combat"][:player][:attack][:knockback],
        from_x: px, from_y: py
      )
      @bus.emit(:attack_hit)
    end

    def overlap?(a, b)
      return false if a.nil? || b.nil?
      a[0] < b[0] + b[2] && b[0] < a[0] + a[2] && a[1] < b[1] + b[3] && b[1] < a[1] + a[3]
    end

    def wire_events
      @bus.subscribe(:attack_hit) { @feel.on_hit }
      @bus.subscribe(:entity_died) do
        @feel.on_kill
        @enemy_respawn_timer = @data["balance/combat"][:enemies][:husk][:respawn_frames]
      end
      @bus.subscribe(:player_hit) { @feel.on_player_hit }
      @bus.subscribe(:player_died) do
        @feel.on_kill
        @respawn_timer = @data["balance/combat"][:player][:respawn_frames]
        @states.transition_to(:death)
      end
      @bus.subscribe(:player_respawned) do
        @enemy_respawn_timer = 0
        spawn_enemy
      end
    end
  end
end
