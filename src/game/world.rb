require "core/event_bus"
require "core/state_stack"
require "core/tile_map"
require "game/player"
require "game/enemy"
require "game/feel"
require "game/camera"
require "game/flow_field"

module Game
  # The whole sim: zones loaded from data/zones/*.json, a player walking the
  # grid between them, husks per zone. Hub-and-spoke doctrine from kethral:
  # town is safe, the dungeon is not, death sends you back to town. Pure and
  # deterministic — same input script in, same state out; never touches Gosu.
  class World
    EVENTS = %i[
      attack_started attack_hit damage_dealt entity_died
      player_hit player_died player_respawned player_dodged
      enemy_telegraph zone_entered
    ].freeze

    TRANSITIONS = { world: %i[death], death: %i[world] }.freeze

    HOME_ZONE = "town".freeze

    attr_reader :bus, :player, :feel, :states, :frame, :camera, :zone_name

    def initialize(data)
      @data = data
      @display = data["display"]
      @bus = Core::EventBus.new.register(*EVENTS)
      @states = Core::StateStack.new(initial: :world, transitions: TRANSITIONS)
      @feel = Feel.new(@data["balance/combat"][:feel])
      @frame = 0
      @respawn_timer = 0
      @banner_timer = 0
      @zones = {}
      @husks = Hash.new { |h, k| h[k] = [] }
      @husk_respawns = Hash.new { |h, k| h[k] = [] }
      load_zones
      spawn_player
      wire_events
      enter_zone(HOME_ZONE, map.player_spawn)
    end

    def map = @zones.fetch(@zone_name)
    def enemies = @husks[@zone_name]
    def banner? = @banner_timer.positive?

    def tick(input)
      if @feel.hitstop?
        @feel.tick
        @bus.process
        @frame += 1
        return
      end

      @banner_timer -= 1 if @banner_timer.positive?

      case @states.current
      when :world
        tick_world(input)
      when :death
        @respawn_timer -= 1
        if @respawn_timer <= 0
          @states.transition_to(:world)
          respawn_player
        end
      end

      @camera.tick(@player.x + Player::SIZE / 2.0, @player.y + Player::SIZE / 2.0)
      @feel.tick
      @bus.process
      @frame += 1
    end

    private

    def tick_world(input)
      @player.tick(input, blocked: occupied_tiles(except: @player))
      check_transition
      tick_enemies
      resolve_player_attack
    end

    def tick_enemies
      flow = flow_field
      enemies.each do |husk|
        husk.tick(player: @player, flow:, blocked: occupied_tiles(except: husk))
      end
      respawn_due_husks
    end

    # One BFS field per zone, recomputed only when the player's tile moves.
    def flow_field
      @flow ||= {}
      field = (@flow[@zone_name] ||= FlowField.new(map))
      if @flow_target != [@zone_name, @player.tile]
        field.recompute!(@player.tile)
        @flow_target = [@zone_name, @player.tile]
      end
      field
    end

    # Everybody body-blocks: no creature steps onto a tile something else
    # logically occupies (Tibia doctrine — the grid is the collision).
    def occupied_tiles(except:)
      tiles = []
      tiles << @player.tile unless except.equal?(@player) || @player.dead?
      enemies.each { |h| tiles << h.tile unless except.equal?(h) || h.dead? }
      tiles
    end

    def check_transition
      return if @player.walker.moving? || @player.dead?
      t = map.transition_at(*@player.tile)
      return unless t
      enter_zone(t[:to], t[:spawn])
    end

    def enter_zone(name, tile)
      raise ArgumentError, "unknown zone #{name}" unless @zones.key?(name)
      @zone_name = name
      @player.rebind(map: map, tile: tile)
      @camera = Camera.new(
        view_w: @display[:view_width], view_h: @display[:view_height],
        world_w: map.pixel_width, world_h: map.pixel_height,
        lerp: @display[:camera_lerp]
      )
      @camera.snap!(@player.x + Player::SIZE / 2.0, @player.y + Player::SIZE / 2.0)
      @banner_timer = @display[:zone_banner_frames]
      @bus.emit(:zone_entered, zone: name)
    end

    def load_zones
      names = @data.keys.grep(%r{\Azones/}).map { |k| k.sub("zones/", "") }
      names.each { |n| @zones[n] = Core::TileMap.new(@data["zones/#{n}"]) }
      seed_husks
    end

    def seed_husks
      @zones.each do |zone, zmap|
        (zmap.enemy_spawns[:husk] || []).each { |tile| add_husk(zone, tile) }
      end
    end

    def add_husk(zone, tile)
      stats = @data["balance/combat"][:enemies][:husk]
      @husks[zone] << Enemy.new(bus: @bus, stats:, map: @zones[zone], tile:)
    end

    def spawn_player
      stats = @data["balance/combat"][:player]
      town = @zones.fetch(HOME_ZONE)
      @zone_name = HOME_ZONE
      @player = Player.new(bus: @bus, stats:, map: town, tile: town.player_spawn)
    end

    def respawn_player
      @zone_name = HOME_ZONE
      @player.respawn(map: map, tile: map.player_spawn)
      enter_zone(HOME_ZONE, map.player_spawn)
    end

    def resolve_player_attack
      return unless @player.attack_can_hit?
      victim = @player.attack_tiles.filter_map { |t| enemies.find { |h| !h.dead? && h.tile == t } }.first
      return unless victim

      @player.attack_landed!
      victim.take_hit(
        damage: @data["balance/combat"][:player][:attack][:damage],
        from_tile: @player.tile
      )
      @bus.emit(:attack_hit)
    end

    def respawn_due_husks
      due, rest = @husk_respawns[@zone_name].partition { |r| r[:at_frame] <= @frame }
      @husk_respawns[@zone_name] = rest
      due.each { |r| add_husk(@zone_name, r[:tile]) }
    end

    def wire_events
      @bus.subscribe(:attack_hit) { @feel.on_hit }
      @bus.subscribe(:entity_died) do
        @feel.on_kill
        schedule_husk_respawns
      end
      @bus.subscribe(:player_hit) { @feel.on_player_hit }
      @bus.subscribe(:player_died) do
        @feel.on_kill
        @respawn_timer = @data["balance/combat"][:player][:respawn_frames]
        @states.transition_to(:death)
      end
    end

    # A dead husk returns at its zone spawn point after the respawn delay.
    def schedule_husk_respawns
      delay = @data["balance/combat"][:enemies][:husk][:respawn_frames]
      dead = enemies.select(&:dead?)
      dead.each do |husk|
        @husk_respawns[@zone_name] << { tile: home_spawn_for(husk), at_frame: @frame + delay }
      end
      enemies.reject!(&:dead?)
    end

    # Respawn at the nearest configured spawn tile for this zone.
    def home_spawn_for(husk)
      spawns = map.enemy_spawns[:husk] || [husk.tile]
      spawns.min_by { |(sx, sy)| (sx - husk.tile[0]).abs + (sy - husk.tile[1]).abs }
    end
  end
end
