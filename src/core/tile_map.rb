module Core
  # Tile map parsed from a zone JSON config. The grid IS the world (Tibia
  # doctrine): a tile is passable or it isn't — no pixel-perfect collision.
  # Engine-agnostic; rendering decides what a wall looks like.
  class TileMap
    class BadMap < StandardError; end

    WALL_CHAR = "#".freeze

    attr_reader :cols, :rows, :tile_size, :pack_spawn, :enemy_spawns,
                :display_name, :palette, :transitions

    def initialize(cfg)
      @tile_size = cfg.fetch(:tile_size)
      @display_name = cfg.fetch(:display_name)
      @palette = cfg.fetch(:palette)
      @grid = cfg.fetch(:tiles).map(&:chars)
      @rows = @grid.length
      @cols = @grid.first.length
      @pack_spawn = cfg.fetch(:pack_spawn)
      @enemy_spawns = cfg.fetch(:enemy_spawns, {})
      @transitions = cfg.fetch(:transitions, [])
      validate!
    end

    def passable?(tx, ty)
      return false if tx.negative? || ty.negative? || tx >= @cols || ty >= @rows
      @grid[ty][tx] != WALL_CHAR
    end

    def wall?(tx, ty) = !passable?(tx, ty)

    def transition_at(tx, ty)
      @transitions.find { |t| t[:at] == [tx, ty] }
    end

    def pixel_width = @cols * @tile_size
    def pixel_height = @rows * @tile_size

    private

    def validate!
      raise BadMap, "empty map" if @rows.zero? || @cols.zero?
      @grid.each_with_index do |row, y|
        raise BadMap, "row #{y} has #{row.length} tiles, expected #{@cols}" if row.length != @cols
      end
      raise BadMap, "pack_spawn needs >= 3 tiles" if @pack_spawn.length < 3
      raise BadMap, "pack_spawn tiles must be distinct" if @pack_spawn.uniq.length != @pack_spawn.length
      @pack_spawn.each { |s| check_passable!("pack_spawn", s) }
      @enemy_spawns.each_value { |spawns| spawns.each { |s| check_passable!("enemy spawn", s) } }
      @transitions.each { |t| check_passable!("transition", t[:at]) }
    end

    def check_passable!(label, (tx, ty))
      raise BadMap, "#{label} [#{tx}, #{ty}] is not passable" unless passable?(tx, ty)
    end
  end
end
