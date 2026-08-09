module App
  # Draws the world sim with Gosu primitives. Flat-rect minimalism per
  # SLICE_SPEC: silhouettes + motion carry readability, not detail. Zone
  # palettes come from data/zones/*.json — the renderer holds no balance
  # or color constants of its own beyond entity identity colors.
  class Renderer
    PLAYER   = Gosu::Color.new(255, 235, 120, 40)
    PLAYER_HURT  = Gosu::Color.new(255, 255, 235, 235)
    HUSK     = Gosu::Color.new(255, 205, 198, 180)
    HUSK_TELEGRAPH = Gosu::Color.new(255, 250, 210, 60)
    HUSK_HURT = Gosu::Color.new(255, 255, 80, 80)
    SLASH    = Gosu::Color.new(200, 255, 255, 255)
    WINDUP   = Gosu::Color.new(90, 255, 255, 255)
    HP_BACK  = Gosu::Color.new(255, 50, 20, 30)
    HP_FILL  = Gosu::Color.new(255, 220, 60, 70)
    DEATH_VEIL = Gosu::Color.new(170, 8, 4, 10)
    BANNER   = Gosu::Color.new(255, 225, 215, 190)

    def draw(world)
      cam = world.camera
      Gosu.translate(world.feel.shake_x - cam.x, world.feel.shake_y - cam.y) do
        draw_map(world.map)
        world.enemies.each { |e| draw_enemy(e) }
        draw_player(world)
      end
      draw_hud(world)
      draw_banner(world) if world.banner?
      draw_death_overlay(world) if world.states.current == :death
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

    def draw_player(world)
      player = world.player
      return if player.dead?
      c =
        if player.invulnerable? && (world.frame / 3).even? then PLAYER_HURT
        else PLAYER
        end
      Gosu.draw_rect(player.x, player.y, Game::Player::SIZE, Game::Player::SIZE, c)
      draw_attack(player, world.map.tile_size)
    end

    # The swing arc shows on its tiles: faint during windup, bright when live.
    def draw_attack(player, ts)
      return unless %i[windup active].include?(player.attack_state)
      c = player.attack_state == :windup ? WINDUP : SLASH
      player.attack_tiles.each do |(tx, ty)|
        Gosu.draw_rect(tx * ts + 4, ty * ts + 4, ts - 8, ts - 8, c)
      end
    end

    def draw_enemy(enemy)
      return if enemy.dead?
      size = Game::Enemy::SIZE
      if enemy.hurt?
        Gosu.draw_rect(enemy.x - 2, enemy.y - 2, size + 4, size + 4, HUSK_HURT)
      elsif enemy.telegraphing?
        swell = 6
        Gosu.draw_rect(enemy.x - swell / 2, enemy.y - swell / 2, size + swell, size + swell, HUSK_TELEGRAPH)
      else
        Gosu.draw_rect(enemy.x, enemy.y, size, size, HUSK)
      end
    end

    def draw_hud(world)
      w = 260
      Gosu.draw_rect(32, 16, w, 14, HP_BACK)
      frac = world.player.hp.fdiv(world.player.max_hp)
      Gosu.draw_rect(32, 16, (w * frac).round, 14, HP_FILL) if frac.positive?
    end

    def draw_banner(world)
      text = world.map.display_name
      font = banner_font
      x = (view_width(world) - font.text_width(text)) / 2
      font.draw_text(text, x, 48, 10, 1, 1, BANNER)
    end

    def draw_death_overlay(world)
      Gosu.draw_rect(0, 0, view_width(world), view_height(world), DEATH_VEIL)
      font = death_font
      text = "YOU DIED"
      x = (view_width(world) - font.text_width(text)) / 2
      font.draw_text(text, x, view_height(world) / 2 - 40, 10, 1, 1, Gosu::Color.new(255, 200, 40, 40))
    end

    def view_width(world) = world.camera.view_w
    def view_height(world) = world.camera.view_h

    def banner_font = @banner_font ||= Gosu::Font.new(28, bold: true)
    def death_font = @death_font ||= Gosu::Font.new(64, bold: true)
  end
end
