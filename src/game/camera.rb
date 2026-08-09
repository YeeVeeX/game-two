module Game
  # Viewport camera: lerps toward centering its target, clamps at the zone
  # edges. Deterministic — a pure function of target positions over frames,
  # so replays stay byte-identical. Ticked by the sim (not the renderer) so
  # captures see the same camera the player does.
  class Camera
    attr_reader :x, :y, :view_w, :view_h

    def initialize(view_w:, view_h:, world_w:, world_h:, lerp:)
      @view_w = view_w
      @view_h = view_h
      @world_w = world_w
      @world_h = world_h
      @lerp = lerp
      @x = 0.0
      @y = 0.0
    end

    def snap!(cx, cy)
      @x = clamp_x(cx - @view_w / 2.0)
      @y = clamp_y(cy - @view_h / 2.0)
    end

    def tick(cx, cy)
      @x += (clamp_x(cx - @view_w / 2.0) - @x) * @lerp
      @y += (clamp_y(cy - @view_h / 2.0) - @y) * @lerp
    end

    private

    def clamp_x(v) = v.clamp(0.0, [@world_w - @view_w, 0].max.to_f)
    def clamp_y(v) = v.clamp(0.0, [@world_h - @view_h, 0].max.to_f)
  end
end
