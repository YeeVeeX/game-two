module App
  # MUNDO VIVO FASE 3 — tiles with a FACE. Neighborhood-derived relief drawn
  # over the flat tile runs: wall faces (the cliff below a wall that meets
  # floor), wall shadows (the dark lip a floor tile wears under a wall),
  # water foam (the pale seam where water meets walkable ground), and a
  # thin light rim on wall tops. All of it is a PURE function of the zone's
  # grid + registry + palette — memoized per map like static_runs, merged
  # horizontally, culled by the renderer's viewport test. Presentation only:
  # passability, flow fields, the sim, the digest — untouched by construction.
  #
  # Colors derive from the zone palette (no new constants: face = wall
  # darkened, foam = water lightened, shadow = near-black alpha) so every
  # zone keeps its own identity while gaining depth. display.json:
  #   tile_faces: true  (whole pass on/off) · grid_lines: false (D7 — with
  #   faces the grid becomes noise; the gate decides, peers ratify).
  module TileArt
    module_function

    FACE_H   = 8   # px: the cliff band at the bottom of a wall over floor
    RIM_H    = 2   # px: light lip on a wall top that meets floor above
    SHADOW_H = 6   # px: dark lip on a floor tile just under a wall
    FOAM_W   = 2   # px: pale seam on a water edge toward walkable ground

    def scale(rgb, k) = rgb.map { |c| (c * k).round.clamp(0, 255) }

    def water_char?(map, tx, ty, specs)
      return false unless map.passable?(tx, ty)
      spec = specs[map.char_at(tx, ty)]
      spec && spec["render"] == "water"
    end

    def floor_char?(map, tx, ty, specs)
      return false unless tx.between?(0, map.cols - 1) && ty.between?(0, map.rows - 1)
      map.passable?(tx, ty) && !water_char?(map, tx, ty, specs)
    end

    def wall_at?(map, tx, ty)
      return true unless tx.between?(0, map.cols - 1) && ty.between?(0, map.rows - 1)
      map.wall?(tx, ty)
    end

    # -> [[x, y, w, h, rgb, alpha], …] in DRAW order (faces → rims → shadows
    # → foam), horizontally merged per class.
    def rects(map, registry)
      ts = map.tile_size
      specs = App::TileVariants.specs(map, registry)
      wall_specs = specs
      pal = map.palette
      faces, rims, shadows, foam = [], [], [], []
      map.rows.times do |ty|
        map.cols.times do |tx|
          x = tx * ts
          y = ty * ts
          if map.wall?(tx, ty)
            ref = App::TileVariants.wall_ref(wall_specs, map, tx, ty)
            wall_rgb = pal[ref] || pal[:wall]
            next unless wall_rgb
            # cliff face: wall with walkable ground directly south
            if floor_char?(map, tx, ty + 1, specs) || water_char?(map, tx, ty + 1, specs)
              faces << [x, y + ts - FACE_H, ts, FACE_H, scale(wall_rgb, 0.62), 255]
            end
            # light rim: wall top that faces open ground above
            if floor_char?(map, tx, ty - 1, specs) || water_char?(map, tx, ty - 1, specs)
              rims << [x, y, ts, RIM_H, scale(wall_rgb, 1.35), 255]
            end
          elsif water_char?(map, tx, ty, specs)
            wrgb = pal[:water] || pal[:floor]
            foam_rgb = scale(wrgb, 1.9).map { |c| [c, 235].min }
            foam << [x, y, ts, FOAM_W, foam_rgb, 150] if floor_char?(map, tx, ty - 1, specs)
            foam << [x, y + ts - FOAM_W, ts, FOAM_W, foam_rgb, 150] if floor_char?(map, tx, ty + 1, specs)
            foam << [x, y, FOAM_W, ts, foam_rgb, 150] if floor_char?(map, tx - 1, ty, specs)
            foam << [x + ts - FOAM_W, y, FOAM_W, ts, foam_rgb, 150] if floor_char?(map, tx + 1, ty, specs)
          else
            # floor under a wall: cast shadow lip
            shadows << [x, y, ts, SHADOW_H, [0, 0, 0], 70] if wall_at?(map, tx, ty - 1)
          end
        end
      end
      merge(faces) + merge(rims) + merge(shadows) + merge(foam)
    end

    # Horizontal merge of abutting rects with identical y/h/rgb/alpha.
    def merge(rects)
      out = []
      rects.each do |r|
        last = out.last
        if last && last[1] == r[1] && last[3] == r[3] && last[4] == r[4] && last[5] == r[5] &&
           last[0] + last[2] == r[0]
          last[2] += r[2]
        else
          out << r.dup
        end
      end
      out
    end
  end
end
