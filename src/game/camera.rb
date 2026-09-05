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

    # A world SMALLER than the view is CENTERED (both bounds collapse to the
    # same negative offset), never pinned to the top-left corner under the
    # HUD (pocket zones, PREMIUM v22 pass 6 re-gate). Worlds larger than the
    # view keep the exact previous clamp. Presentation only: the camera is
    # excluded from the digest by law.
    def clamp_x(v) = v.clamp([@world_w - @view_w, 0].min.to_f, [@world_w - @view_w, 0].max.to_f)
    def clamp_y(v) = v.clamp([@world_h - @view_h, 0].min.to_f, [@world_h - @view_h, 0].max.to_f)
  end
end
