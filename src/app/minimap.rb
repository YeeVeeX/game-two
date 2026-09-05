require "gosu"

module App
  # PREMIUM v22 pass 9 — MINIMAP (the ARPG radar). A 128x80 box top-right,
  # 2 px per tile, centered on the possessed body: walls in the zone's wall
  # color, floor darker, water blue, open ways gold, stations magenta; live
  # dots for hostiles (red), pack bodies (kit color) and YOU (gold with a
  # dark ring). Shows ~4x the camera's area, so the next door is on the
  # radar long before it is on camera.
  #
  # The zone image is built ONCE per map from immutable zone config (a raw
  # RGBA blob -> Gosu::Image, retro) and drawn as a cached subimage window
  # keyed by the possessed tile; dots are live draws. Presentation only,
  # tick-free (reads positions, never the clock), nothing in the digest.
  # display.json: minimap (on/off), minimap_rect, minimap_scale.
  class Minimap
    RawBlob = Struct.new(:columns, :rows, :to_blob)

    def initialize(display:, kit_body:)
      @display = display
      @kit_body = kit_body
      @enabled = display.fetch(:minimap, true)
      @images = {}
      @windows = {}
    end

    def enabled? = @enabled

    # The box in screen space (x, y, w, h) — exit arrows and pips avoid it.
    def rect(view_w)
      w, h = @display.fetch(:minimap_size, [128, 80])
      [view_w - w - 12, 12, w, h]
    end

    def scale = @display.fetch(:minimap_scale, 2)

    # --- zone image -------------------------------------------------------------
    def zone_image(map, registry)
      @images[map] ||= build_zone_image(map, registry)
    end

    def build_zone_image(map, registry)
      s = scale
      specs = App::TileVariants.specs(map, registry)
      pal = map.palette
      floor = lift(pal[:floor] || [40, 36, 32], 28)
      wall = pal[:wall] || [120, 120, 120]
      water = lift(pal[:water] || [30, 60, 90], 28)
      gold = pal[:transition] || [235, 190, 90]
      station = [200, 90, 220]
      w = map.cols * s
      h = map.rows * s
      blob = String.new(capacity: w * h * 4)
      rows = Array.new(map.rows) do |ty|
        Array.new(map.cols) do |tx|
          spec = specs[map.char_at(tx, ty)]
          rgb =
            if map.transition_at(tx, ty) then gold
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
      img = zone_image(map, world.tile_registry)
      return unless img
      cam = world.camera(local_seat)
      bx, by, bw, bh = rect(cam.view_w)
      s = scale
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
        dot.call(h, (h.kit[:boss] || h.kit[:seize]) ? [255, 60, 60] : [225, 70, 50], (h.kit[:boss] ? 4 : 3), h.kit[:boss])
      end
      world.pack.living.each do |m|
        next if m.equal?(me)
        col = @kit_body[m.kit_name]
        dot.call(m, [col.red, col.green, col.blue], 3, true)
      end
      dot.call(me, [255, 220, 120], 4, true) if me
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
