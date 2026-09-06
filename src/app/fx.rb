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
    NUM_FRAMES = 40
    CALLOUT_FRAMES = 54
    CHIP_DIRS = [[1, -1], [-1, -1], [1, 1], [-1, 1], [0, -1], [1, 0]].freeze

    # labels = { drink:, roll:, special: } already translated by the renderer
    def initialize(display:, kit_body:, labels: {})
      @display = display
      @kit_body = kit_body
      @labels = labels
      @worlds = {}   # world -> { sparks:, bursts:, dust:, last_tile: {creature => tile} }
      @enabled = display.fetch(:fx_enabled, true)
    end

    def state_for(world)
      @worlds[world] ||= begin
        st = { sparks: [], bursts: [], dust: [], nums: [], last_tile: {}, last_hp: {},
               callouts: [], acts: {}, last_sp: {} }
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
          # pass 7 ALLY CALLOUTS: a FREE ally announces what it did (Junior,
          # 2026-09-05: "não notei diferença nos aliados" — the brain acted,
          # nothing on screen said so). drink / roll come from the bus; the
          # special from the state poll in #update. Never for the possessed
          # (you know what you did) — ally acts only.
          # pass 10: PICKUP burst — a gold sparkle ring + "+N" over the body
          # that gleaned (the ledger panel tallies; this says WHERE, now).
          world.bus.subscribe(:drop_picked_up) do |ev|
            a = ev.payload[:actor]
            next unless a
            st[:bursts] << { x: a.x + 14, y: a.y + 8, at: world.frame, rgb: [255, 214, 120], pickup: true }
            st[:nums] << { x: a.x + 14, y: a.y - 10, at: world.frame, text: "+#{ev.payload[:amount]}", kind: :gold, big: false }
          end
          world.bus.subscribe(:item_picked_up) do |ev|
            a = ev.payload[:actor]
            next unless a
            st[:bursts] << { x: a.x + 14, y: a.y + 8, at: world.frame, rgb: [235, 225, 200], pickup: true }
            name = @labels[:item]&.call(ev.payload[:item]) || ev.payload[:item].to_s.upcase
            qty = ev.payload[:qty].to_i
            st[:callouts] << { c: a, kind: :item, at: world.frame, rgb: [235, 225, 200],
                               text: qty > 1 ? "#{name} x#{qty}" : name }
            st[:acts][a.kit_name] = world.frame
          end
          world.bus.subscribe(:item_used) do |ev|
            a = ev.payload[:actor]
            next unless a
            name = @labels[:item]&.call(ev.payload[:item]) || ev.payload[:item].to_s.upcase
            st[:callouts] << { c: a, kind: :item, at: world.frame, rgb: [120, 235, 110], text: name }
            st[:acts][a.kit_name] = world.frame
          end
          world.bus.subscribe(:bag_full) do |ev|
            a = ev.payload[:actor]
            next unless a
            st[:callouts] << { c: a, kind: :full, at: world.frame, rgb: [240, 90, 80], text: @labels[:bag_full].to_s }
          end
          world.bus.subscribe(:provision_used) do |ev|
            a = ev.payload[:actor]
            next unless a && a.faction == :pack && !controlled?(world, a)
            callout!(st, world, a, :drink)
          end
          world.bus.subscribe(:dodged) do |ev|
            a = ev.payload[:actor]
            next unless a && a.faction == :pack && !controlled?(world, a)
            callout!(st, world, a, :roll)
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
        # pass 6: floating numbers from the hp DELTA between polls (catches
        # melee, shots, poison/aura ticks and heals alike — no payload change)
        hp0 = st[:last_hp][c]
        st[:last_hp][c] = c.hp
        if hp0 && hp0 != c.hp && @display.fetch(:fx_damage_numbers, true)
          d = c.hp - hp0
          st[:nums] << { x: c.x + 14, y: c.y - 6, at: world.frame, text: (d.positive? ? "+#{d}" : (-d).to_s),
                         kind: d.positive? ? :heal : (c.faction == :pack ? :taken : :dealt),
                         big: -d >= (c.max_hp * 0.25) }
        end
        # special windup START on a free ally -> callout (poll: the sim emits
        # no special event; presentation reads the state edge)
        if c.faction == :pack && !controlled?(world, c)
          sp = c.attack_state == :windup && c.respond_to?(:current_action) && c.current_action == :special
          callout!(st, world, c, :special) if sp && !st[:last_sp][c]
          st[:last_sp][c] = sp
        end
        prev = st[:last_tile][c]
        st[:last_tile][c] = c.tile
        next if prev.nil? || prev == c.tile
        # a step: puff behind the body (opposite the facing), on the ground
        fx, fy = c.facing
        st[:dust] << { x: c.x + 14 - fx * 10, y: c.y + 26 - fy * 4, at: world.frame, dir: [-fx, -fy] }
      end
      st[:last_tile].delete_if { |c, _| !seen[c] }
      st[:last_hp].delete_if { |c, _| !seen[c] }
      st[:last_sp].delete_if { |c, _| !seen[c] }
      f = world.frame
      st[:callouts].reject! { |p| f - p[:at] >= CALLOUT_FRAMES }
      st[:nums].reject! { |p| f - p[:at] >= NUM_FRAMES }
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

    # Numbers + callouts draw ABOVE bodies (call after the creature pass).
    def draw_numbers(world, z: 8)
      return unless @enabled
      st = state_for(world)
      f = world.frame
      st[:nums].each { |p| draw_number(p, f - p[:at], z) }
      st[:callouts].each { |p| draw_callout(p, f - p[:at], z + 1) }
    end

    # kit_name -> frame of the ally's last announced act (the HUD pulses its
    # row for a few frames). {} when nothing happened.
    def acts(world) = state_for(world)[:acts]

    private

    def controlled?(world, c)
      world.respond_to?(:controlled?) ? world.controlled?(c) : world.possessed.equal?(c)
    end

    def callout!(st, world, c, kind)
      return unless @display.fetch(:fx_ally_callouts, true)
      st[:callouts] << { c: c, kind: kind, at: world.frame, rgb: rgb_of(c) }
      st[:acts][c.kit_name] = world.frame
    end

    # A small icon (flask / chevron / kit glyph) + label rising from the
    # ally's head, holding, then fading — quiet, not a combat element.
    def draw_callout(p, age, z)
      c = p[:c]
      t = age.fdiv(CALLOUT_FRAMES)
      rise = age < 8 ? age * 2 : 16
      a = t < 0.7 ? 255 : (255 * (1.0 - (t - 0.7) / 0.3)).round.clamp(0, 255)
      cx = c.x + 14
      y = c.y - 22 - rise
      label = p[:text] || @labels[p[:kind]].to_s
      f = num_font
      tw = f.text_width(label)
      w = tw + 18
      x0 = (cx - w / 2).round
      Gosu.draw_rect(x0 - 1, y - 1, w + 2, 13, Gosu::Color.new((a * 0.85).round, 14, 10, 10), z)
      rr, gg, bb = p[:rgb]
      Gosu.draw_rect(x0 - 1, y - 1, w + 2, 1, Gosu::Color.new(a, rr, gg, bb), z)
      ix = x0 + 2
      case p[:kind]
      when :drink
        Gosu.draw_rect(ix + 3, y + 1, 3, 2, Gosu::Color.new(a, 220, 220, 230), z)
        Gosu.draw_rect(ix + 1, y + 3, 7, 7, Gosu::Color.new(a, 230, 90, 140), z)
        Gosu.draw_rect(ix + 2, y + 4, 2, 3, Gosu::Color.new(a, 255, 180, 210), z)
      when :roll
        [[7, 0], [5, 1], [3, 2], [1, 3]].each do |(ww, k)|
          Gosu.draw_rect(ix + 4 - ww / 2.0, y + 2 + k * 2, ww, 2, Gosu::Color.new(a, 190, 215, 255), z)
        end
      when :item, :full
        Gosu.draw_rect(ix + 1, y + 1, 8, 8, Gosu::Color.new(a, rr, gg, bb), z)
        Gosu.draw_rect(ix + 3, y + 4, 4, 3, Gosu::Color.new(a, 20, 14, 12), z)
      else
        Gosu.draw_rect(ix + 1, y + 1, 8, 8, Gosu::Color.new(a, rr, gg, bb), z)
        Gosu.draw_rect(ix + 3, y + 3, 4, 4, Gosu::Color.new(a, 255, 255, 240), z)
      end
      halo = Gosu::Color.new(a, 20, 12, 12)
      tx = x0 + 14
      [[1, 0], [-1, 0], [0, 1], [0, -1]].each { |(dx, dy)| f.draw_text(label, tx + dx, y - 1 + dy, z, 1, 1, halo) }
      f.draw_text(label, tx, y - 1, z, 1, 1, Gosu::Color.new(a, 245, 240, 225))
    end

    public

    # A number rises ~18px with ease-out and fades over the last third.
    # dealt = warm white (yellow when >= 25% of the victim's max: a BIG hit),
    # taken = crimson (your body bled), heal = green. Dark 1px halo so it
    # reads on any ground. Not magenta, never in the HUD: the carried
    # numeral keeps its grammar.
    def draw_number(p, age, z)
      t = age.fdiv(NUM_FRAMES)
      rise = (18 * (1 - (1 - t) * (1 - t))).round
      a = t < 0.66 ? 255 : (255 * (1.0 - (t - 0.66) / 0.34)).round.clamp(0, 255)
      col = case p[:kind]
            when :heal then Gosu::Color.new(a, 120, 235, 110)
            when :gold then Gosu::Color.new(a, 255, 214, 120)
            when :taken then Gosu::Color.new(a, 240, 70, 60)
            else p[:big] ? Gosu::Color.new(a, 255, 225, 90) : Gosu::Color.new(a, 250, 245, 230)
            end
      f = p[:big] ? big_font : num_font
      tw = f.text_width(p[:text])
      x = (p[:x] - tw / 2).round
      y = p[:y] - rise - (p[:big] ? 4 : 0)
      halo = Gosu::Color.new(a, 20, 12, 12)
      [[1, 0], [-1, 0], [0, 1], [0, -1]].each { |(dx, dy)| f.draw_text(p[:text], x + dx, y + dy, z, 1, 1, halo) }
      f.draw_text(p[:text], x, y, z, 1, 1, col)
    end

    def num_font = @num_font ||= Gosu::Font.new(@display.fetch(:fx_number_font_px, 13))
    def big_font = @big_font ||= Gosu::Font.new(@display.fetch(:fx_number_big_px, 17))

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
      if p[:pickup]
        # gleam: 8 sparks rising and fading, no flash ring, no falling chips
        a = (255 * (1.0 - t)).round
        8.times do |k|
          ang = k * Math::PI / 4 + 0.3
          r = 4 + age * 0.9
          sx = x + Math.cos(ang) * r
          sy = y + Math.sin(ang) * r * 0.6 - age * 0.8
          Gosu.draw_rect(sx, sy, 2, 2, Gosu::Color.new(a, 255, 240, 200), z)
        end
        return
      end
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
