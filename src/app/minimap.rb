require "gosu"

module App
  # PREMIUM v22 pass 9 — MINIMAP (the ARPG radar). A 128x80 box top-right,
  # 2 px per tile, centered on the possessed body: walls in the zone's wall
  # color, floor darker, water blue, OPEN ways gold, LOCKED ways cold grey,
  # stations magenta; live dots for hostiles (red), pack bodies (kit color)
  # and YOU (gold with a dark ring). Shows ~4x the camera's area, so the
  # next door is on the radar long before it is on camera.
  #
  # The zone image is built ONCE per (map, lock state) from zone config + the
  # way locks (a raw RGBA blob -> Gosu::Image, retro) and drawn as a cached
  # subimage window keyed by the possessed tile; dots are live draws. E3 b4
  # (T0 finding b4/d12): gold means WALKABLE (exit_signage law) - a way's
  # color comes from the SAME predicate the floor signage and the exit
  # arrows read (Renderer.way_locked?), never from a list of its own; a
  # breach / level-up / boss defeat repaints the image once. Presentation
  # only, tick-free (reads positions + lock facts, never the clock), nothing
  # in the digest. display.json: minimap (on/off), minimap_size,
  # minimap_scale(_max), minimap_dot_extra, minimap_way_open_rgb,
  # minimap_way_locked_rgb.
  class Minimap
    RawBlob = Struct.new(:columns, :rows, :to_blob)

    def initialize(display:, kit_body:)
      @display = display
      @kit_body = kit_body
      @enabled = display.fetch(:minimap)
      @images = {}
      @windows = {}
    end

    def enabled? = @enabled

    # The box in screen space (x, y, w, h) — exit arrows and pips avoid it.
    def rect(view_w)
      w, h = @display.fetch(:minimap_size)
      [view_w - w - 12, 12, w, h]
    end

    # px per tile: the base scale, RAISED for zones smaller than the box so a
    # pocket (16x14) fills it and clustered dots separate (at 2 px/tile five
    # adjacent husks + the pack read as one orange blob - basement wall #3).
    # Capped by minimap_scale_max; per map, so the cached image matches.
    def scale_for(map)
      w, h = @display.fetch(:minimap_size)
      base = @display.fetch(:minimap_scale)
      fit = [w / map.cols, h / map.rows].min
      fit.clamp(base, @display.fetch(:minimap_scale_max))
    end

    # Pure (E3 b4): the way tile's radar color - nil when (tx, ty) is not a
    # way; OPEN = the zone's transition gold (minimap_way_open_rgb when the
    # palette names none), LOCKED = minimap_way_locked_rgb. ONE predicate
    # with the floor signage + exit arrows: Renderer.way_locked?.
    def way_color(map, world, tx, ty)
      t = map.transition_at(tx, ty)
      return nil unless t
      if App::Renderer.way_locked?(world, world.zone_name, t)
        @display.fetch(:minimap_way_locked_rgb)
      else
        map.palette[:transition] || @display.fetch(:minimap_way_open_rgb)
      end
    end

    # The lock facts the image bakes: the sorted tiles of every locked way
    # (the cache key beside the map - a fact change repaints once).
    def locked_ways(map, world)
      map.transitions.select { |t| App::Renderer.way_locked?(world, world.zone_name, t) }.map { |t| t[:at] }.sort
    end

    # --- zone image -------------------------------------------------------------
    def zone_image(map, world, registry)
      @images.clear if @images.length > 64
      @images[[map, locked_ways(map, world)]] ||= build_zone_image(map, world, registry)
    end

    def build_zone_image(map, world, registry)
      s = scale_for(map)
      specs = App::TileVariants.specs(map, registry)
      pal = map.palette
      floor = lift(pal[:floor] || [40, 36, 32], 28)
      wall = pal[:wall] || [120, 120, 120]
      water = lift(pal[:water] || [30, 60, 90], 28)
      station = [200, 90, 220]
      w = map.cols * s
      h = map.rows * s
      blob = String.new(capacity: w * h * 4)
      rows = Array.new(map.rows) do |ty|
        Array.new(map.cols) do |tx|
          spec = specs[map.char_at(tx, ty)]
          rgb =
            if (way = way_color(map, world, tx, ty)) then way
            elsif map.station_at(tx, ty) then station
            elsif spec.nil? || spec["passability"] == "wall" then wall
            elsif spec["render"] == "water" then water
            else
              typed = pal[spec["render"].to_sym]
              typed ? lift(typed, 20) : floor
            end
          [rgb[0], rgb[1], rgb[2], 235].pack("C4")
        end
      end
      map.rows.times do |ty|
        s.times do
          map.cols.times { |tx| s.times { blob << rows[ty][tx] } }
        end
      end
      Gosu::Image.new(RawBlob.new(w, h, blob), retro: true)
    rescue StandardError
      nil
    end

    def lift(rgb, k) = rgb.map { |c| (c + k).clamp(0, 255) }

    # --- draw -----------------------------------------------------------------------
    def draw(world, local_seat)
      return unless @enabled
      map = world.map
      img = zone_image(map, world, world.tile_registry)
      return unless img
      cam = world.camera(local_seat)
      bx, by, bw, bh = rect(cam.view_w)
      s = scale_for(map)
      me = world.possessed(local_seat)
      ctx, cty = me ? me.tile : map.pack_spawn.first
      # window origin in zone-image pixels (clamped; small zones center)
      iw = map.cols * s
      ih = map.rows * s
      ox = iw <= bw ? -((bw - iw) / 2) : (ctx * s - bw / 2).clamp(0, iw - bw)
      oy = ih <= bh ? -((bh - ih) / 2) : (cty * s - bh / 2).clamp(0, ih - bh)
      z = 19
      # plate + frame
      Gosu.draw_rect(bx - 2, by - 2, bw + 4, bh + 4, Gosu::Color.new(255, 16, 12, 12), z)
      Gosu.draw_rect(bx - 1, by - 1, bw + 2, bh + 2, Gosu::Color.new(255, 70, 56, 44), z)
      Gosu.draw_rect(bx, by, bw, bh, Gosu::Color.new(255, 12, 10, 10), z)
      # zone window (cached subimage per origin)
      sub = window(img, ox, oy, bw, bh, iw, ih)
      sub[:img].draw(bx + sub[:dx], by + sub[:dy], z + 1)
      # dots: hostiles, pack, you
      dot = lambda do |c, rgb, size, ring|
        tx, ty = c.tile
        px = bx + tx * s - ox
        py = by + ty * s - oy
        next unless px.between?(bx, bx + bw - size) && py.between?(by, by + bh - size)
        Gosu.draw_rect(px - 1, py - 1, size + 2, size + 2, Gosu::Color.new(255, 10, 8, 8), z + 2) if ring
        Gosu.draw_rect(px, py, size, size, Gosu::Color.new(255, *rgb), z + 2)
      end
      world.humans.each do |h|
        next if h.dead?
        ex = @display.fetch(:minimap_dot_extra) # {hostile:, boss:, pack:, you:} px over the scale
        dot.call(h, (h.kit[:boss] || h.kit[:seize]) ? [255, 60, 60] : [225, 70, 50], s + (h.kit[:boss] ? ex[:boss] : ex[:hostile]), h.kit[:boss])
      end
      world.pack.living.each do |m|
        next if m.equal?(me)
        col = @kit_body[m.kit_name]
        dot.call(m, [col.red, col.green, col.blue], s + @display.fetch(:minimap_dot_extra)[:pack], true)
      end
      dot.call(me, [255, 220, 120], s + @display.fetch(:minimap_dot_extra)[:you], true) if me
    end

    # Subimage of the zone image for the window; small zones (image smaller
    # than the box) draw whole, offset to center. Cache capped.
    def window(img, ox, oy, bw, bh, iw, ih)
      key = [img, ox, oy]
      @windows.clear if @windows.length > 400
      @windows[key] ||= begin
        sx = [ox, 0].max
        sy = [oy, 0].max
        w = [bw, iw - sx].min
        h = [bh, ih - sy].min
        { img: img.subimage(sx, sy, w, h), dx: ox.negative? ? -ox : 0, dy: oy.negative? ? -oy : 0 }
      end
    end
  end
end
