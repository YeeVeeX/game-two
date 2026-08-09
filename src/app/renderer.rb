module App
  # Draws the world sim with Gosu primitives. Flat-rect minimalism: the
  # possessed body is the brightest thing on screen with a white possession
  # ring; allies are dimmer kin; humans (husk kit, M1) pale bone. Palettes
  # come from data/zones/*.json.
  class Renderer
    POSSESSED      = Gosu::Color.new(255, 235, 120, 40)
    POSSESSED_RING = Gosu::Color.new(255, 255, 255, 255)
    ALLY           = Gosu::Color.new(255, 165, 90, 40)
    HURT_FLASH     = Gosu::Color.new(255, 255, 235, 235)
    HUMAN          = Gosu::Color.new(255, 205, 198, 180)
    TELEGRAPH      = Gosu::Color.new(255, 250, 210, 60)
    HUMAN_HURT     = Gosu::Color.new(255, 255, 80, 80)
    SLASH          = Gosu::Color.new(200, 255, 255, 255)
    WINDUP         = Gosu::Color.new(90, 255, 255, 255)
    HP_BACK        = Gosu::Color.new(255, 50, 20, 30)
    HP_FILL        = Gosu::Color.new(255, 220, 60, 70)
    WIPE_VEIL      = Gosu::Color.new(170, 8, 4, 10)
    BANNER         = Gosu::Color.new(255, 225, 215, 190)
    STAGGER_VEIL   = Gosu::Color.new(90, 20, 8, 8)

    SIZE = Game::Creature::SIZE

    def draw(world)
      cam = world.camera
      Gosu.translate(world.feel.shake_x - cam.x, world.feel.shake_y - cam.y) do
        draw_map(world.map)
        world.humans.each { |h| draw_creature(h, world) }
        world.pack.living.each { |m| draw_creature(m, world) }
      end
      draw_hud(world)
      draw_banner(world) if world.banner?
      draw_wipe_overlay(world) if world.states.current == :nest_respawn
      draw_stagger_veil(world) if world.possessed.staggered?
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

    def draw_creature(c, world)
      return if c.dead?
      if c.equal?(world.possessed)
        Gosu.draw_rect(c.x - 3, c.y - 3, SIZE + 6, SIZE + 6, POSSESSED_RING)
      end
      if c.faction == :human && c.telegraphing?
        swell = 6
        Gosu.draw_rect(c.x - swell / 2, c.y - swell / 2, SIZE + swell, SIZE + swell, TELEGRAPH)
      else
        Gosu.draw_rect(c.x, c.y, SIZE, SIZE, body_color(c, world))
      end
      draw_attack(c, world.map.tile_size) if c.faction == :pack
    end

    def body_color(c, world)
      if c.hurt? && c.faction == :human then HUMAN_HURT
      elsif c.faction == :human then HUMAN
      elsif c.iframes? && (world.frame / 3).even? then HURT_FLASH
      elsif c.equal?(world.possessed) then POSSESSED
      else ALLY
      end
    end

    def draw_attack(c, ts)
      return unless %i[windup active].include?(c.attack_state)
      col = c.attack_state == :windup ? WINDUP : SLASH
      c.attack_tiles.each do |(tx, ty)|
        Gosu.draw_rect(tx * ts + 4, ty * ts + 4, ts - 8, ts - 8, col)
      end
    end

    def draw_hud(world)
      w = 260
      c = world.possessed
      Gosu.draw_rect(32, 16, w, 14, HP_BACK)
      frac = c.hp.fdiv(c.max_hp)
      Gosu.draw_rect(32, 16, (w * frac).round, 14, HP_FILL) if frac.positive?
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
  end
end
