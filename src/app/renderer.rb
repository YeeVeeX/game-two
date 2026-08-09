module App
  # Draws the arena sim with Gosu primitives. Flat-rect minimalism per
  # SLICE_SPEC: silhouettes + motion carry readability, not detail.
  # Pure function of arena state — holds no state of its own except colors.
  class Renderer
    FLOOR    = Gosu::Color.new(255, 15, 15, 25)
    GRID     = Gosu::Color.new(255, 22, 22, 34)
    WALL     = Gosu::Color.new(255, 40, 40, 58)
    PLAYER   = Gosu::Color.new(255, 235, 120, 40)
    PLAYER_DODGE = Gosu::Color.new(160, 235, 120, 40)
    PLAYER_HURT  = Gosu::Color.new(255, 255, 235, 235)
    HUSK     = Gosu::Color.new(255, 205, 198, 180)
    HUSK_TELEGRAPH = Gosu::Color.new(255, 250, 210, 60)
    HUSK_HURT = Gosu::Color.new(255, 255, 80, 80)
    SLASH    = Gosu::Color.new(200, 255, 255, 255)
    WINDUP   = Gosu::Color.new(90, 255, 255, 255)
    HP_BACK  = Gosu::Color.new(255, 50, 20, 30)
    HP_FILL  = Gosu::Color.new(255, 220, 60, 70)
    DEATH_VEIL = Gosu::Color.new(170, 8, 4, 10)

    GRID_STEP = 48

    def draw(arena)
      Gosu.translate(arena.feel.shake_x, arena.feel.shake_y) do
        draw_room(arena)
        draw_enemy(arena.enemy)
        draw_player(arena.player, arena.frame)
        draw_hud(arena)
      end
      draw_death_overlay(arena) if arena.states.current == :death
    end

    private

    def draw_room(arena)
      w = Game::Arena::WIDTH
      h = Game::Arena::HEIGHT
      wall = Game::Arena::WALL
      Gosu.draw_rect(0, 0, w, h, WALL)
      Gosu.draw_rect(wall, wall, w - 2 * wall, h - 2 * wall, FLOOR)
      (wall...(w - wall)).step(GRID_STEP) { |x| Gosu.draw_rect(x, wall, 1, h - 2 * wall, GRID) }
      (wall...(h - wall)).step(GRID_STEP) { |y| Gosu.draw_rect(wall, y, w - 2 * wall, 1, GRID) }
    end

    def draw_player(player, frame)
      return if player.dead?
      color =
        if player.invulnerable? && (frame / 3).even? then PLAYER_HURT
        elsif player.dodging? then PLAYER_DODGE
        else PLAYER
        end
      Gosu.draw_rect(player.x, player.y, Game::Player::SIZE, Game::Player::SIZE, color)
      draw_attack(player)
    end

    def draw_attack(player)
      case player.attack_state
      when :windup
        box = windup_box(player)
        Gosu.draw_rect(*box, WINDUP)
      when :active
        Gosu.draw_rect(*player.attack_hitbox, SLASH)
      end
    end

    # Faint preview of where the swing will land.
    def windup_box(player)
      size = Game::Player::SIZE
      range = player.attack_range
      cx = player.x + size / 2 + player.facing[0] * (size / 2 + range / 2)
      cy = player.y + size / 2 + player.facing[1] * (size / 2 + range / 2)
      [cx - range / 2.0, cy - range / 2.0, range, range]
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

    def draw_hud(arena)
      w = 260
      Gosu.draw_rect(32, 16, w, 14, HP_BACK)
      frac = arena.player.hp.fdiv(arena.player.max_hp)
      Gosu.draw_rect(32, 16, (w * frac).round, 14, HP_FILL) if frac.positive?
    end

    def draw_death_overlay(arena)
      Gosu.draw_rect(0, 0, Game::Arena::WIDTH, Game::Arena::HEIGHT, DEATH_VEIL)
      font = death_font
      text = "YOU DIED"
      x = (Game::Arena::WIDTH - font.text_width(text)) / 2
      font.draw_text(text, x, Game::Arena::HEIGHT / 2 - 40, 10, 1, 1, Gosu::Color.new(255, 200, 40, 40))
    end

    def death_font
      @death_font ||= Gosu::Font.new(64, bold: true)
    end
  end
end
