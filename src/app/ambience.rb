module App
  # MUNDO VIVO FASE 2 — living maps. Animated ambient layers (water shimmer,
  # bubbles, torch flicker, sparks, sway, drips, motes…) drawn between the
  # static tile pass and the ambient tint, UNDER every actor.
  #
  # Laws (lane G, recorded 2026-08-30 + AGENTS tick-driven law):
  #   1. TICK-DRIVEN, never wall-clock: every animated value is a pure
  #      function of (world.frame, source seed, preset data). Both gate
  #      halves and both netplay seats draw the same pixels; replays stay
  #      byte-identical across machines. No Gosu.milliseconds, no rand.
  #   2. Presentation only: nothing here is read by the sim; nothing enters
  #      the state digest. Zones opt in by DATA (three doors):
  #        (a) data/tiles.json  type "ambience": "<preset>" (+ density)
  #            → every tile of that type animates, in every zone;
  #        (b) zone regions[] "ambience": "<preset>" (+ density, tiles)
  #            → an area breathes (the floor -2 underwater pilot);
  #        (c) zone decor[] {"kind": "ambience", "at": [x,y], "preset": …}
  #            → a point source (torch, brazier, vent).
  #   3. Culled by the existing viewport test; display.json `ambience: false`
  #      switches the whole layer off (perf/debug). Re-pin law: a zone that
  #      gains ambience re-cuts its wall manifests as a NAMED ticket cost.
  #
  # Presets live in data/ambience.json — a small layer DSL (rect / band /
  # tri / spark), each with period, drift, wobble, alpha curve, flicker.
  module Ambience
    # 64-entry integer sine (±1000) — deterministic wobble, no Math.sin.
    SIN = Array.new(64) { |i| (Math.sin(i * Math::PI * 2 / 64) * 1000).round }.freeze

    class Layer
      def self.load(presets_cfg)
        (presets_cfg || {}).to_h do |name, layers|
          [name.to_s, layers.map { |l| new(l) }]
        end
      end

      attr_reader :shape, :w, :h, :dx, :dy, :rgb, :rgb2, :a0, :a1, :period,
                  :y_drift, :x_wobble, :curve, :flicker, :count, :spread, :tall

      def initialize(l)
        @shape = l.fetch(:shape).to_s
        @w = l.fetch(:w, 4)
        @h = l.fetch(:h, 4)
        @dx = l.fetch(:dx, 0)
        @dy = l.fetch(:dy, 0)
        @rgb = l.fetch(:rgb)
        @rgb2 = l[:rgb2]
        @a0, @a1 = l.fetch(:alpha, [40, 120])
        @period = [l.fetch(:period, 60), 1].max
        @y_drift = l.fetch(:y_drift, 0)
        @x_wobble = l.fetch(:x_wobble, 0)
        @curve = l.fetch(:curve, "pulse").to_s
        @flicker = l.fetch(:flicker, 0)
        @count = l.fetch(:count, 1)
        @spread = l.fetch(:spread, 0)
        @tall = l.fetch(:tall, 0)
      end
    end

    # FNV-1a over a stable string — the TileVariants law (never Object#hash).
    def self.seed(zone, tx, ty, k = 0)
      h = 2_166_136_261
      "#{zone}:#{tx}:#{ty}:#{k}".each_byte { |b| h = ((h ^ b) * 16_777_619) & 0xffffffff }
      h
    end

    # 0..1 envelope of a layer at phase p (0..1).
    def self.envelope(curve, p)
      case curve
      when "rise" then p < 0.15 ? p / 0.15 : (1.0 - p) / 0.85        # bubbles/sparks: fade out
      when "fall" then p < 0.85 ? 1.0 : (1.0 - p) / 0.15            # drips: sharp end
      when "flat" then 1.0
      else (SIN[(p * 63).to_i] + 1000) / 2000.0                     # pulse
      end
    end

    class Scene
      def initialize(presets, display: {})
        @presets = presets
        @enabled = display.fetch(:ambience)
        @cache = {}
      end

      def enabled? = @enabled && !@presets.empty?

      # Sources for a map, memoized per map: [[preset_name, tx, ty, seed],…].
      # Pure function of zone config + registry — never state.
      def sources(map, registry)
        @cache[map] ||= build_sources(map, registry)
      end

      def build_sources(map, registry)
        out = []
        zone = map.name.to_s
        specs = App::TileVariants.specs(map, registry)
        typed = specs.each_with_object({}) do |(ch, spec), h|
          h[ch] = spec if spec && spec["ambience"]
        end
        unless typed.empty?
          map.rows.times do |ty|
            map.cols.times do |tx|
              spec = typed[map.char_at(tx, ty)]
              next unless spec
              s = Ambience.seed(zone, tx, ty)
              density = spec.fetch("ambience_density", 1.0)
              next if (s % 1000) >= density * 1000
              out << [spec["ambience"].to_s, tx, ty, s] if @presets.key?(spec["ambience"].to_s)
            end
          end
        end
        map.regions.each do |r|
          next unless r[:ambience] && @presets.key?(r[:ambience].to_s)
          rx, ry, rw, rh = r[:rect]
          density = r.fetch(:ambience_density, 0.25)
          allowed = r[:ambience_tiles]&.map(&:to_s)
          (ry...(ry + rh)).each do |ty|
            (rx...(rx + rw)).each do |tx|
              next unless tx.between?(0, map.cols - 1) && ty.between?(0, map.rows - 1)
              next if allowed && !allowed.include?(map.char_at(tx, ty))
              s = Ambience.seed("#{zone}/#{r[:id]}", tx, ty, 1)   # never Object#hash (per-process salt)
              next if (s % 1000) >= density * 1000
              out << [r[:ambience].to_s, tx, ty, s]
            end
          end
        end
        map.decor.each do |d|
          next unless d[:kind] == "ambience" && @presets.key?(d.fetch(:preset).to_s)
          tx, ty = d.fetch(:at)
          out << [d[:preset].to_s, tx, ty, Ambience.seed(zone, tx, ty, 7)]
        end
        out
      end

      # Draws every visible source at world.frame. camera = the seat camera
      # (world coords, inside the renderer's translate block).
      def draw(world, camera, registry)
        return unless enabled?
        map = world.map
        ts = map.tile_size
        frame = world.frame
        sources(map, registry).each do |(name, tx, ty, s)|
          px = tx * ts
          py = ty * ts
          next unless App::Renderer.rect_visible?([px - ts, py - ts * 2, ts * 3, ts * 3], camera)
          @presets[name].each { |layer| draw_layer(layer, px, py, ts, frame, s) }
        end
      end

      def draw_layer(l, px, py, ts, frame, s)
        l.count.times do |k|
          sk = (s >> (k * 5)) & 0xffff
          phase = ((frame + sk) % l.period).fdiv(l.period)
          env = Ambience.envelope(l.curve, phase)
          alpha = (l.a0 + (l.a1 - l.a0) * env).round.clamp(0, 255)
          next if alpha <= 0
          spread_x = l.spread.zero? ? 0 : ((sk % (l.spread * 2 + 1)) - l.spread)
          wobble = l.x_wobble.zero? ? 0 : (SIN[((phase * 63).to_i + (sk % 64)) % 64] * l.x_wobble) / 1000
          x = px + l.dx + spread_x + wobble
          y = py + l.dy - (l.y_drift * phase).round
          rgb = l.rgb
          if l.rgb2 && l.flicker.positive? && (((frame + sk) / l.flicker) % 2).zero?
            rgb = l.rgb2
          end
          col = Gosu::Color.new(alpha, *rgb)
          case l.shape
          when "rect", "spark"
            Gosu.draw_rect(x, y, l.w, l.h, col)
          when "band"
            Gosu.draw_rect(px + 2, y, ts - 4, l.h, col)
          when "tri"
            # flame: a triangle whose tip flickers in height
            hh = l.h + (l.tall.zero? ? 0 : (SIN[((frame + sk) * 3) % 64] * l.tall) / 1000)
            Gosu.draw_triangle(x, y + l.h, col, x + l.w, y + l.h, col, x + l.w / 2, y + l.h - hh, col)
          end
        end
      end
    end

    def self.load(data, display: {})
      cfg = begin
        data["ambience"]
      rescue Core::DataStore::MissingKey
        nil
      end
      Scene.new(Layer.load(cfg&.fetch(:presets, nil)), display:)
    end
  end
end
