module App
  # Draws the world sim with Gosu primitives. Flat-rect minimalism: kit
  # identity is COLOR + silhouette behavior; the possessed body is brightened
  # and white-ringed. Carried vision-critique fixes live here: facing notch,
  # crimson (never white) pack hurt-flash, two-tone telegraph distinct from
  # gate gold, corpses persist, attack lunge. Palettes from data/zones/*.json.
  class Renderer
    HUMAN_BODY = Gosu::Color.new(255, 205, 198, 180) # pale bone
    KIT_BODY = Hash.new(HUMAN_BODY).merge(
      striker: Gosu::Color.new(255, 235, 120, 40),
      blocker: Gosu::Color.new(255, 190, 80, 35),
      lobber:  Gosu::Color.new(255, 225, 170, 90)
    ).freeze

    POSSESSED_RING = Gosu::Color.new(255, 255, 255, 255)
    ALLY_DIM       = Gosu::Color.new(120, 10, 8, 12)  # overlay that dims unpossessed kin
    PACK_HURT      = Gosu::Color.new(255, 200, 30, 30) # crimson, never white (critique)
    HUMAN_HURT     = Gosu::Color.new(255, 255, 80, 80)
    TELEGRAPH_EDGE = Gosu::Color.new(255, 235, 60, 40)  # hot red border...
    TELEGRAPH_CORE = Gosu::Color.new(255, 250, 210, 60) # ...around the yellow core (≠ gate gold)
    SLASH          = Gosu::Color.new(220, 255, 255, 255)
    WINDUP         = Gosu::Color.new(90, 255, 255, 255)
    SPECIAL_WINDUP = Gosu::Color.new(120, 255, 190, 90)
    SPECIAL_ACTIVE = Gosu::Color.new(235, 255, 225, 150)
    LUNGE_WINDUP   = Gosu::Color.new(110, 255, 125, 45)
    LUNGE_ACTIVE   = Gosu::Color.new(245, 255, 245, 210)
    PROJECTILE     = Gosu::Color.new(255, 250, 235, 170)
    VOLLEY_EDGE    = Gosu::Color.new(220, 245, 125, 35)
    VOLLEY_CORE    = Gosu::Color.new(235, 255, 220, 150)
    MARK_GLYPH     = Gosu::Color.new(255, 75, 235, 205)
    DROP_CORE      = Gosu::Color.new(255, 205, 70, 225) # glean drops — magenta/violet, owned by no other element
    NOTCH          = Gosu::Color.new(255, 20, 14, 12)
    HP_BACK        = Gosu::Color.new(255, 50, 20, 30)
    HP_DEAD        = Gosu::Color.new(255, 35, 25, 30)
    WIPE_VEIL      = Gosu::Color.new(170, 8, 4, 10)
    BANNER         = Gosu::Color.new(255, 225, 215, 190)
    STAGGER_VEIL   = Gosu::Color.new(90, 20, 8, 8)

    SIZE = Game::Creature::SIZE

    def draw(world)
      cam = world.camera
      Gosu.translate(world.feel.shake_x - cam.x, world.feel.shake_y - cam.y) do
        draw_map(world.map)
        draw_impacts(world)
        draw_corpses(world)
        draw_stations(world)
        draw_drops(world)
        world.humans.each { |h| draw_creature(h, world) }
        world.pack.living.each { |m| draw_creature(m, world) }
        world.projectiles.each { |p| draw_projectile(p) }
        draw_mark(world)
        draw_station_ledger(world)
      end
      draw_hud(world)
      draw_edge_pips(world)
      draw_banner(world) if world.banner?
      draw_wipe_overlay(world) if world.states.current == :nest_respawn
      draw_stagger_veil(world) if world.possessed.staggered?
    end

    def draw_impacts(world)
      ts = world.map.tile_size
      world.impacts.each do |impact|
        delay = impact[:owner].kit[:special][:delay_frames]
        size = 6 + (impact[:frames_left].fdiv(delay) * 10).round
        impact[:tiles].each do |(tx, ty)|
          x = tx * ts
          y = ty * ts
          Gosu.draw_rect(x + 4, y + 4, ts - 8, 3, VOLLEY_EDGE)
          Gosu.draw_rect(x + 4, y + ts - 7, ts - 8, 3, VOLLEY_EDGE)
          Gosu.draw_rect(x + 4, y + 7, 3, ts - 14, VOLLEY_EDGE)
          Gosu.draw_rect(x + ts - 7, y + 7, 3, ts - 14, VOLLEY_EDGE)
          inset = (ts - size) / 2.0
          Gosu.draw_rect(x + inset, y + inset, size, size, VOLLEY_CORE)
        end
      end
    end

    def draw_mark(world)
      target = world.marked_target
      return unless target && !target.dead?
      x = target.x - 5
      y = target.y - 5
      span = SIZE + 10
      arm = 8
      thick = 3
      [[x, y], [x + span - arm, y], [x, y + span - thick],
       [x + span - arm, y + span - thick]].each do |(cx, cy)|
        Gosu.draw_rect(cx, cy, arm, thick, MARK_GLYPH)
      end
      [[x, y], [x + span - thick, y], [x, y + span - arm],
       [x + span - thick, y + span - arm]].each do |(cx, cy)|
        Gosu.draw_rect(cx, cy, thick, arm, MARK_GLYPH)
      end
      Gosu.draw_rect(target.x + SIZE / 2 - 2, target.y - 9, 4, 4, MARK_GLYPH)
    end

    private

    def color(rgb, alpha = 255) = Gosu::Color.new(alpha, rgb[0], rgb[1], rgb[2])

    def draw_map(map)
      ts = map.tile_size
      floor = color(map.palette[:floor])
      grid = color(map.palette[:grid])
      wall = color(map.palette[:wall])
      transition = color(map.palette[:transition])

      Gosu.draw_rect(0, 0, map.pixel_width, map.pixel_height, floor)
      map.rows.times do |ty|
        map.cols.times do |tx|
          Gosu.draw_rect(tx * ts, ty * ts, ts, ts, wall) if map.wall?(tx, ty)
        end
      end
      (0..map.cols).each { |tx| Gosu.draw_rect(tx * ts, 0, 1, map.pixel_height, grid) }
      (0..map.rows).each { |ty| Gosu.draw_rect(0, ty * ts, map.pixel_width, 1, grid) }
      map.transitions.each do |t|
        tx, ty = t[:at]
        Gosu.draw_rect(tx * ts + 3, ty * ts + 3, ts - 6, ts - 6, transition)
      end
    end

    # Drops: small magenta squares; size steps with amount (1 vs 2+), alpha
    # fades over the final third of the decay clock (visible rot, like
    # corpse fade). decay_frames rides each drop — no balance read here.
    def draw_drops(world)
      ts = world.map.tile_size
      world.drops.each do |d|
        size = d[:amount] >= 2 ? 14 : 10
        frac = d[:frames_left].fdiv(d[:decay_frames])
        alpha = frac < (1 / 3.0) ? (255 * frac * 3).clamp(60, 255).round : 255
        tx, ty = d[:tile]
        inset = (ts - size) / 2.0
        col = Gosu::Color.new(alpha, DROP_CORE.red, DROP_CORE.green, DROP_CORE.blue)
        Gosu.draw_rect(tx * ts + inset, ty * ts + inset, size, size, col)
        Gosu.draw_rect(tx * ts + inset + 3, ty * ts + inset + 3, size - 6, size - 6,
                       Gosu::Color.new(alpha, 250, 225, 255)) # pale violet-white core
      end
    end

    # Station fixture: palette-driven block with a hollow center — reads as
    # a PLACE, not a wall (walls are solid) and not a gate (gates are gold).
    def draw_stations(world)
      ts = world.map.tile_size
      world.map.stations.each do |s|
        tx, ty = s[:at]
        x = tx * ts
        y = ty * ts
        Gosu.draw_rect(x + 2, y + 2, ts - 4, ts - 4,
                       color(world.map.palette[:station] || world.map.palette[:wall]))
        Gosu.draw_rect(x + 8, y + 8, ts - 16, ts - 16, color(world.map.palette[:floor]))
      end
    end

    # Banked total shows ONLY at the station, only when the possessed is
    # near (quiet-HUD law: the world HUD never carries the score). Radius 3,
    # not 2: GridWalker commits the tile at step START while the pixel tween
    # trails, so a body that LOOKS adjacent can already be 3 tiles away —
    # the numeral must read whenever the player would say "I'm at it".
    LEDGER_RADIUS_TILES = 3

    def draw_station_ledger(world)
      world.map.stations.each do |s|
        tx, ty = s[:at]
        px, py = world.possessed.tile
        next unless [(tx - px).abs, (ty - py).abs].max <= LEDGER_RADIUS_TILES
        ts = world.map.tile_size
        text = world.pack.banked.to_s
        hud_font.draw_text(text, tx * ts + (ts - hud_font.text_width(text)) / 2,
                           ty * ts - 18, 10, 1, 1, DROP_CORE)
      end
    end

    # Bodies stay where they fell and fade out (critique: vanishing kills
    # erase the fight's history).
    def draw_corpses(world)
      world.corpses.each do |c|
        age = world.frame - c[:at_frame]
        alpha = (140 * (1.0 - age.fdiv(Game::World::CORPSE_FADE_FRAMES))).clamp(0, 140).round
        base = c[:faction] == :human ? [140, 135, 125] : [150, 80, 40]
        Gosu.draw_rect(c[:x] + 4, c[:y] + 10, SIZE - 8, SIZE - 14,
                       Gosu::Color.new(alpha, *base))
      end
    end

    def draw_creature(c, world)
      lx, ly = lunge_offset(c)
      x = c.x + lx
      y = c.y + ly
      if c.equal?(world.possessed)
        Gosu.draw_rect(x - 3, y - 3, SIZE + 6, SIZE + 6, POSSESSED_RING)
      end
      if c.faction == :human && c.telegraphing?
        swell = 8
        Gosu.draw_rect(x - swell / 2, y - swell / 2, SIZE + swell, SIZE + swell, TELEGRAPH_EDGE)
        Gosu.draw_rect(x - 2, y - 2, SIZE + 4, SIZE + 4, TELEGRAPH_CORE)
        # The body stays visible INSIDE the flare: two adjacent telegraphing
        # humans otherwise read as an ownerless ground-tile pattern,
        # indistinguishable from Volley target tiles (gate critique finding).
        Gosu.draw_rect(x + 5, y + 5, SIZE - 10, SIZE - 10, HUMAN_BODY)
      else
        Gosu.draw_rect(x, y, SIZE, SIZE, body_color(c, world))
        Gosu.draw_rect(x, y, SIZE, SIZE, ALLY_DIM) if ally?(c, world)
      end
      draw_facing_notch(c, x, y)
      draw_attack(c, world.map.tile_size) if c.faction == :pack
    end

    def ally?(c, world) = c.faction == :pack && !c.equal?(world.possessed)

    def body_color(c, world)
      if c.faction == :pack && c.iframes? && (world.frame / 3).even?
        PACK_HURT
      elsif c.faction == :human && c.hurt?
        HUMAN_HURT
      elsif c.faction == :pack && c.hurt? && (world.frame / 3).even?
        PACK_HURT
      else
        KIT_BODY[c.kit_name]
      end
    end

    # Which way a body faces must be readable at a glance (critique fix):
    # a dark notch on the facing edge.
    def draw_facing_notch(c, x, y)
      fx, fy = c.facing
      n = 6
      nx = fx.positive? ? x + SIZE - n : x
      ny = fy.positive? ? y + SIZE - n : y
      if fx.zero? # vertical facing: notch spans centered horizontally
        Gosu.draw_rect(x + SIZE / 2 - n / 2, ny, n, n, NOTCH)
      elsif fy.zero?
        Gosu.draw_rect(nx, y + SIZE / 2 - n / 2, n, n, NOTCH)
      else # diagonal: corner notch
        Gosu.draw_rect(nx, ny, n, n, NOTCH)
      end
    end

    # Weight shifts into the swing (critique fix): sink back on windup,
    # lunge forward on active. Draw-only — tiles never move.
    def lunge_offset(c)
      return [0, 0] unless c.faction == :pack
      return [0, 0] if c.current_action == :special
      fx, fy = c.facing
      case c.attack_state
      when :windup then [-3 * fx, -3 * fy]
      when :active then [6 * fx, 6 * fy]
      else [0, 0]
      end
    end

    def draw_attack(c, ts)
      return unless %i[windup active].include?(c.attack_state)
      if c.current_action == :special && c.action_config[:arc] == "dash"
        col = c.attack_state == :windup ? LUNGE_WINDUP : LUNGE_ACTIVE
        inset = c.attack_state == :windup ? 10 : 6
        c.action_tiles.each do |(tx, ty)|
          Gosu.draw_rect(tx * ts + inset, ty * ts + inset,
                         ts - inset * 2, ts - inset * 2, col)
        end
        return
      end
      col =
        if c.current_action == :special
          c.attack_state == :windup ? SPECIAL_WINDUP : SPECIAL_ACTIVE
        else
          c.attack_state == :windup ? WINDUP : SLASH
        end
      c.action_tiles.each do |(tx, ty)|
        Gosu.draw_rect(tx * ts + 4, ty * ts + 4, ts - 8, ts - 8, col)
      end
    end

    def draw_projectile(p)
      Gosu.draw_rect(p.x, p.y, Game::Projectile::SIZE, Game::Projectile::SIZE, PROJECTILE)
    end

    # Three kit-colored bars; the possessed one is wider, white-edged, and
    # carries the exhaust-ready pip.
    def draw_hud(world)
      world.pack.members.each_with_index do |m, i|
        y = 16 + i * 20
        mine = m.equal?(world.possessed)
        w = mine ? 260 : 200
        x = 32
        Gosu.draw_rect(x - 2, y - 2, w + 4, 18, POSSESSED_RING) if mine
        Gosu.draw_rect(x, y, w, 14, m.dead? ? HP_DEAD : HP_BACK)
        frac = m.hp.fdiv(m.max_hp)
        if frac.positive?
          Gosu.draw_rect(x, y, (w * frac).round, 14, KIT_BODY[m.kit_name])
        end
        attack_pip = !m.dead? && m.exhaust_ready? ? POSSESSED_RING : HP_BACK
        special_ready = !m.dead? && m.kit[:special] && m.special_ready?
        special_pip = special_ready ? KIT_BODY[m.kit_name] : HP_BACK
        Gosu.draw_rect(300, y + 2, 10, 10, attack_pip)
        Gosu.draw_rect(314, y + 2, 10, 10, special_pip)
        Gosu.draw_rect(317, y + 5, 4, 4, POSSESSED_RING) if special_ready
        # Carried numeral: possessed bar only, reserved slot right of the
        # pips — layout never shifts (quiet-HUD law).
        if mine && m.carried.positive?
          hud_font.draw_text(m.carried.to_s, 332, y, 20, 1, 1, DROP_CORE)
        end
      end
    end

    # Living off-screen kin show as kit-colored pips clamped to the viewport
    # edge toward their true position — ally state is never invisible.
    def draw_edge_pips(world)
      cam = world.camera
      world.pack.living.each do |m|
        next if m.equal?(world.possessed)
        sx = m.x - cam.x
        sy = m.y - cam.y
        on_screen = sx > -SIZE && sx < cam.view_w && sy > -SIZE && sy < cam.view_h
        next if on_screen
        px = (sx + SIZE / 2).clamp(6, cam.view_w - 16)
        py = (sy + SIZE / 2).clamp(6, cam.view_h - 16)
        Gosu.draw_rect(px, py, 10, 10, KIT_BODY[m.kit_name])
      end
    end

    def draw_banner(world)
      text = world.map.display_name
      font = banner_font
      x = (view_width(world) - font.text_width(text)) / 2
      font.draw_text(text, x, 48, 10, 1, 1, BANNER)
    end

    def draw_wipe_overlay(world)
      Gosu.draw_rect(0, 0, view_width(world), view_height(world), WIPE_VEIL)
      font = wipe_font
      text = "THE HUNT ENDS" # fiction-pending: wipe line comes from the bible
      x = (view_width(world) - font.text_width(text)) / 2
      font.draw_text(text, x, view_height(world) / 2 - 40, 10, 1, 1, Gosu::Color.new(255, 200, 40, 40))
    end

    # Forced swap lands with a one-beat red edge so losing a body FEELS lost.
    def draw_stagger_veil(world)
      Gosu.draw_rect(0, 0, view_width(world), view_height(world), STAGGER_VEIL)
    end

    def view_width(world) = world.camera.view_w
    def view_height(world) = world.camera.view_h

    def banner_font = @banner_font ||= Gosu::Font.new(28, bold: true)
    def wipe_font = @wipe_font ||= Gosu::Font.new(64, bold: true)
    def hud_font = @hud_font ||= Gosu::Font.new(14)
  end
end
