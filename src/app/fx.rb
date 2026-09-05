require "gosu"

module App
  # PREMIUM v22 pass 3 — IMPACT. Presentation-only particles fed by the sim's
  # own event bus and by pure polling of body positions:
  #   * hit spark: a 4-point star + 3 flying chips where an attack LANDED
  #   * death burst: a white flash ring + 6 kit-colored chips at the fallen body
  #   * footstep dust: a puff behind a body that just changed tile
  # Every particle is keyed by the WORLD FRAME at spawn and aged by
  # world.frame — no clock, no RNG (offsets come from fixed tables indexed
  # by (frame + tile) so the two gate halves and both seats draw the same
  # pixels). Nothing here is read by the sim; nothing lands in the digest.
  # Subscription happens once per World (the bus is world-owned) on first
  # draw — both gate halves subscribe at the same frame by construction.
  class Fx
    SPARK_FRAMES = 12
    BURST_FRAMES = 22
    DUST_FRAMES = 14
    CHIP_DIRS = [[1, -1], [-1, -1], [1, 1], [-1, 1], [0, -1], [1, 0]].freeze

    def initialize(display:, kit_body:)
      @display = display
      @kit_body = kit_body
      @worlds = {}   # world -> { sparks:, bursts:, dust:, last_tile: {creature => tile} }
      @enabled = display.fetch(:fx_enabled, true)
    end

    def state_for(world)
      @worlds[world] ||= begin
        st = { sparks: [], bursts: [], dust: [], last_tile: {} }
        if world.respond_to?(:bus)
          world.bus.subscribe(:attack_hit) do |ev|
            v = ev.payload[:victim]
            next unless v && ev.payload[:landed]
            st[:sparks] << { x: v.x + 14, y: v.y + 10, at: world.frame, pack: v.faction == :pack }
          end
          world.bus.subscribe(:actor_died) do |ev|
            a = ev.payload[:actor]
            next unless a
            st[:bursts] << { x: a.x + 14, y: a.y + 14, at: world.frame, rgb: rgb_of(a) }
          end
        end
        st
      end
    end

    # Polls body tiles for footstep dust and prunes aged particles. Call
    # once per draw BEFORE drawing (idempotent per frame: guarded by frame).
    def update(world)
      return unless @enabled
      st = state_for(world)
      return if st[:frame] == world.frame
      st[:frame] = world.frame
      bodies = world.pack.living + world.humans.reject(&:dead?)
      seen = {}
      bodies.each do |c|
        seen[c] = true
        prev = st[:last_tile][c]
        st[:last_tile][c] = c.tile
        next if prev.nil? || prev == c.tile
        # a step: puff behind the body (opposite the facing), on the ground
        fx, fy = c.facing
        st[:dust] << { x: c.x + 14 - fx * 10, y: c.y + 26 - fy * 4, at: world.frame, dir: [-fx, -fy] }
      end
      st[:last_tile].delete_if { |c, _| !seen[c] }
      f = world.frame
      st[:sparks].reject! { |p| f - p[:at] >= SPARK_FRAMES }
      st[:bursts].reject! { |p| f - p[:at] >= BURST_FRAMES }
      st[:dust].reject! { |p| f - p[:at] >= DUST_FRAMES }
    end

    def draw(world, z: 6)
      return unless @enabled
      st = state_for(world)
      f = world.frame
      st[:dust].each { |p| draw_dust(p, f - p[:at], z) }
      st[:sparks].each { |p| draw_spark(p, f - p[:at], z + 1) }
      st[:bursts].each { |p| draw_burst(p, f - p[:at], z + 1) }
    end

    private

    def rgb_of(c)
      col = @kit_body[c.kit_name]
      col ? [col.red, col.green, col.blue] : [205, 198, 180]
    end

    # 4-point star that grows then thins (frames 0..11) + 3 chips flying out.
    def draw_spark(p, age, z)
      t = age.fdiv(SPARK_FRAMES)
      len = age < 4 ? 4 + age * 3 : (16 - (age - 4) * 1.6).round
      thick = age < 4 ? 3 : (age < 8 ? 2 : 1)
      a = (255 * (1.0 - t)).round
      core = Gosu::Color.new(a, 255, 255, 240)
      warm = Gosu::Color.new(a, 255, 200, 90)
      x, y = p[:x], p[:y]
      Gosu.draw_rect(x - len, y - thick / 2, len * 2, thick, warm, z)
      Gosu.draw_rect(x - thick / 2, y - len, thick, len * 2, warm, z)
      d = (len * 0.6).round
      Gosu.draw_rect(x - d, y - d, thick, thick, core, z)
      Gosu.draw_rect(x + d - thick, y - d, thick, thick, core, z)
      Gosu.draw_rect(x - d, y + d - thick, thick, thick, core, z)
      Gosu.draw_rect(x + d - thick, y + d - thick, thick, thick, core, z)
      Gosu.draw_rect(x - 2, y - 2, 4, 4, core, z) if age < 5
      # chips: 3 fixed directions, decelerating, falling
      CHIP_DIRS.first(3).each_with_index do |(dx, dy), k|
        cx = x + dx * (age * 2.2 + k)
        cy = y + dy * (age * 1.6) + (age * age) / 9.0
        Gosu.draw_rect(cx, cy, 2, 2, p[:pack] ? Gosu::Color.new(a, 235, 60, 60) : warm, z)
      end
    end

    # White flash ring expanding + 6 kit-colored chips arcing out and down.
    def draw_burst(p, age, z)
      t = age.fdiv(BURST_FRAMES)
      x, y = p[:x], p[:y]
      if age < 6
        a = (230 * (1.0 - age / 6.0)).round
        r = 6 + age * 4
        w = Gosu::Color.new(a, 255, 255, 250)
        Gosu.draw_rect(x - r, y - 2, r * 2, 4, w, z)
        Gosu.draw_rect(x - 2, y - r, 4, r * 2, w, z)
        Gosu.draw_rect(x - r + 2, y - r + 2, r * 2 - 4, r * 2 - 4, Gosu::Color.new(a / 3, 255, 255, 250), z)
      end
      a = (255 * (1.0 - t)).round
      rr, gg, bb = p[:rgb]
      col = Gosu::Color.new(a, rr, gg, bb)
      dark = Gosu::Color.new(a, rr / 2, gg / 2, bb / 2)
      CHIP_DIRS.each_with_index do |(dx, dy), k|
        sp = 2.4 + (k % 3) * 0.5
        cx = x + dx * age * sp
        cy = y + dy * age * (sp * 0.7) + (age * age) / 7.0
        s = k.even? ? 3 : 2
        Gosu.draw_rect(cx, cy, s, s, col, z)
        Gosu.draw_rect(cx + s - 1, cy + s - 1, 1, 1, dark, z)
      end
    end

    # Ground puff: 3 pale specks drifting back and up, fading.
    def draw_dust(p, age, z)
      t = age.fdiv(DUST_FRAMES)
      a = (110 * (1.0 - t)).round
      c = Gosu::Color.new(a, 220, 205, 180)
      dx, dy = p[:dir]
      [[0, 0, 3], [-3, -1, 2], [3, 1, 2]].each do |(ox, oy, s)|
        x = p[:x] + ox + dx * age * 0.8
        y = p[:y] + oy + dy * age * 0.3 - age * 0.5
        Gosu.draw_rect(x, y, s, s, c, z)
      end
    end
  end
end
