module Core
  # Tile map parsed from a zone JSON config. The grid IS the world (Tibia
  # doctrine): a tile is passable or it isn't — no pixel-perfect collision.
  # Engine-agnostic; rendering decides what a wall looks like.
  class TileMap
    class BadMap < StandardError; end

    WALL_CHAR = "#".freeze

    attr_reader :cols, :rows, :tile_size, :pack_spawn, :enemy_spawns,
                :display_name, :palette, :transitions, :stations, :drop_gradient,
                :hub, :gradient_anchor, :name, :decor

    def initialize(cfg)
      @tile_size = cfg.fetch(:tile_size)
      # v13 i18n: internal zone name keys locale lookups ("zone.<name>.…");
      # optional so fixture maps stay valid — nil name just falls back to
      # the canonical display_name at render.
      @name = cfg.fetch(:name, nil)
      @display_name = cfg.fetch(:display_name)
      @palette = cfg.fetch(:palette)
      @grid = cfg.fetch(:tiles).map(&:chars)
      @rows = @grid.length
      @cols = @grid.first.length
      @pack_spawn = cfg.fetch(:pack_spawn)
      @enemy_spawns = cfg.fetch(:enemy_spawns, {})
      @transitions = cfg.fetch(:transitions, [])
      @stations = cfg.fetch(:stations, [])
      @drop_gradient = cfg.fetch(:drop_gradient, nil)
      # v12: hub zones re-anchor the pack's home; the gradient anchor pins
      # the gate-field origin so arrival-list ORDER can never flip a zone's
      # band map (sorted zone keys reorder arrivals when zones are added).
      @hub = cfg.fetch(:hub, false)
      @gradient_anchor = cfg.fetch(:gradient_anchor, nil)
      # v16 (b): authored landmark rects — RENDER-ONLY paint (silhouette
      # identity; never blocking, so passability is deliberately not
      # checked — a stain may lie across walls).
      @decor = cfg.fetch(:decor, [])
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

    def station_at(tx, ty)
      @stations.find { |s| s[:at] == [tx, ty] }
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
      @stations.each { |s| check_passable!("station", s[:at]) }
      check_passable!("gradient_anchor", @gradient_anchor) if @gradient_anchor
      @decor.each { |d| check_decor!(d) }
    end

    def check_decor!(d)
      at = d.fetch(:at) { raise BadMap, "decor entry needs at:" }
      size = d.fetch(:size) { raise BadMap, "decor entry needs size:" }
      d.fetch(:rgb) { raise BadMap, "decor entry needs rgb:" }
      tx, ty = at
      w, h = size
      return if tx >= 0 && ty >= 0 && w.positive? && h.positive? &&
                tx + w <= @cols && ty + h <= @rows
      raise BadMap, "decor [#{tx}, #{ty}] #{w}x#{h} out of bounds"
    end

    def check_passable!(label, (tx, ty))
      raise BadMap, "#{label} [#{tx}, #{ty}] is not passable" unless passable?(tx, ty)
    end
  end
end
