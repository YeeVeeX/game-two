require "gosu"

module App
  # MUNDO VIVO FASE 1 — the art layer. Sprites enter UNDER the existing
  # legibility overlays (possession ring, marks, underlines, telegraph
  # flare, pressure outline, facing notch): the renderer keeps its grammar,
  # the body just stops being a bare quad. Contract:
  #
  #   data/art/manifest.json — per kit: {atlas, cols, rows, anims, md5};
  #   atlas grid = ROWS facings (down, up, left, right) x COLS frames.
  #   Frame choice is a PURE function of (world.frame, creature state,
  #   facing) — deterministic, so both gate halves and both netplay seats
  #   pick the same frame. Nothing here is read by the sim; nothing lands
  #   in the state digest.
  #
  #   Fallback law: kit without a manifest entry (or manifest/atlas absent)
  #   → Body.draw returns false and the renderer draws the legacy quad.
  #   Adding a kit never breaks a build.
  #
  #   ART IS REPLACEABLE: same grid, new PNG (Gabriel's assets later),
  #   zero code. tools/gen_placeholder_art.py is the v1 pipeline proof.
  module Art
    class Registry
      # Loads manifest metadata only — Gosu images are created LAZILY on the
      # first draw (a GL context must exist; DataStore is built before the
      # window in some harness paths). Returns a Registry with zero kits
      # when the manifest is absent (fallback law).
      def self.load(data)
        manifest = begin
          data["art/manifest"]
        rescue Core::DataStore::MissingKey
          nil
        end
        new(manifest, data.root)
      end

      attr_reader :frame_w, :frame_h, :anchor, :facings

      def initialize(manifest, root)
        @root = root
        @frame_w = manifest&.fetch(:frame_w, 32) || 32
        @frame_h = manifest&.fetch(:frame_h, 32) || 32
        @anchor = manifest&.fetch(:anchor, [2, 2]) || [2, 2]
        @facings = (manifest&.fetch(:facings, nil) || %w[down up left right]).map(&:to_s)
        @kits = {}
        (manifest&.fetch(:kits, nil) || {}).each do |kit, spec|
          @kits[kit.to_sym] = Atlas.new(spec, root: root, registry: self)
        end
      end

      def kits = @kits.keys.sort
      def atlas_for(kit_name) = @kits[kit_name&.to_sym]
      def facing_row(facing) = @facings.index(facing) || 0
    end

    class Atlas
      attr_reader :path, :cols, :rows, :anims, :md5

      def initialize(spec, root:, registry:)
        @path = File.join(root.to_s, spec.fetch(:atlas))
        @cols = spec.fetch(:cols)
        @rows = spec.fetch(:rows)
        @anims = spec.fetch(:anims).transform_keys(&:to_sym)
        @md5 = spec[:md5]
        @registry = registry
        @tiles = nil
        @failed = false
      end

      def exists? = File.file?(@path)

      # Frame indices of an anim (Integer columns); falls back to idle.
      def frames(anim)
        (@anims[anim] || @anims[:idle]).fetch(:frames)
      end

      def frames_per_step(anim)
        (@anims[anim] || @anims[:idle]).fetch(:frames_per_step, 1)
      end

      # Lazy tile load; nil (→ quad fallback) when the PNG is missing or
      # Gosu refuses — a broken atlas degrades, never crashes the frame.
      def tiles
        return nil if @failed
        @tiles ||= begin
          Gosu::Image.load_tiles(@path, @registry.frame_w, @registry.frame_h,
                                 retro: true, tileable: false)
        rescue StandardError
          @failed = true
          nil
        end
      end

      def tile(row, col)
        t = tiles
        return nil unless t
        t[row * @cols + col]
      end
    end

    module Body
      module_function

      # Which manifest row a creature faces. Diagonals resolve to the
      # dominant axis (vertical wins ties) — the notch overlay keeps the
      # exact 8-way truth on top.
      def facing_name(c)
        fx, fy = c.facing
        if fy.abs >= fx.abs && !fy.zero?
          fy.positive? ? "down" : "up"
        elsif fx.negative?
          "left"
        else
          "right"
        end
      end

      # Anim selection mirrors the renderer's state reads (dead > hurt >
      # attack windup/active > walk > idle). Pure: same inputs, same anim.
      # pass 5: i-frames come ONLY from a dodge or a dash-special (Creature:
      # take_hit never grants them), so i-frames without hurt = the body is
      # ROLLING, not recoiling -> :dodge (falls back to idle in an atlas
      # without the anim, by Atlas#frames' law).
      def anim_for(c)
        return :dead if c.dead?
        return :hurt if c.hurt?
        return :dodge if c.respond_to?(:iframes?) && c.iframes?
        # pass 5b: a SPECIAL in flight wears its own silhouette (Atlas#frames
        # falls back to idle for an atlas without the anim).
        special = c.respond_to?(:current_action) && c.current_action == :special
        case c.attack_state
        when :windup then special ? :special_windup : :windup
        when :active then special ? :special_active : :active
        else c.moving? ? :walk : :idle
        end
      end

      # Frame column for (anim, world frame) — cycles by frames_per_step.
      def frame_col(atlas, anim, world_frame)
        fr = atlas.frames(anim)
        step = [atlas.frames_per_step(anim), 1].max
        fr[(world_frame / step) % fr.length]
      end

      # Draws the body sprite at the creature's pixel position (x, y are the
      # body's top-left, i.e. the legacy quad origin). tint = Gosu::Color
      # modulation (crimson hurt flash, ally dim, seized weight) or nil.
      # Returns true when a sprite was drawn, false → caller draws the quad.
      def draw(c, world, x, y, registry, tint: nil, z: 0)
        return false unless registry
        atlas = registry.atlas_for(c.kit_name)
        return false unless atlas
        row = registry.facing_row(facing_name(c))
        img = atlas.tile(row, frame_col(atlas, anim_for(c), world.frame))
        return false unless img
        ax, ay = registry.anchor
        # PREMIUM v22 pass 3: a struck body SQUASHES (wider, shorter) for the
        # hurt window, anchored at the feet — impact you can see without a
        # number. hurt_frames counts down 8..1 (Creature#take_hit); squash
        # decays with it. Pure function of creature state (no clock).
        hf = c.respond_to?(:hurt_frames) ? c.hurt_frames : 0
        if hf.positive? && !c.dead?
          k = hf.fdiv(8).clamp(0.0, 1.0)
          sx = 1.0 + 0.18 * k
          sy = 1.0 - 0.14 * k
          fw = registry.frame_w
          fh = registry.frame_h
          # feet = frame bottom minus the 6px shadow rows; keep them fixed
          feet_y = y - ay + fh - 6
          cx = x - ax + fw / 2.0
          img.draw(cx - fw * sx / 2.0, feet_y - (fh - 6) * sy, z, sx, sy, tint || Gosu::Color::WHITE)
        else
          img.draw(x - ax, y - ay, z, 1, 1, tint || Gosu::Color::WHITE)
        end
        true
      end

      # The DEAD frame of a kit (down row) for corpse presentation; nil ->
      # caller draws the legacy corpse rect.
      def dead_image(kit_name, registry)
        return nil unless registry
        atlas = registry.atlas_for(kit_name)
        return nil unless atlas
        atlas.tile(registry.facing_row("down"), atlas.frames(:dead).first)
      end
    end
  end
end
