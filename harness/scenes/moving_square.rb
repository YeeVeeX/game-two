# Phase 0 proving scene: a square driven by the input abstraction.
# Pure deterministic sim — 4px per held-frame, no wall clock anywhere.
module Harness
  module Scenes
    class MovingSquare
      SPEED = 4
      SIZE = 64

      attr_reader :x, :y

      def initialize(width:, height:)
        @width = width
        @height = height
        @x = 40
        @y = (height - SIZE) / 2
      end

      def tick(input)
        @x += SPEED if input.down?(:right)
        @x -= SPEED if input.down?(:left)
        @y += SPEED if input.down?(:down)
        @y -= SPEED if input.down?(:up)
      end

      def draw
        Gosu.draw_rect(0, 0, @width, @height, Gosu::Color.new(255, 15, 15, 25))
        Gosu.draw_rect(@x, @y, SIZE, SIZE, Gosu::Color.new(255, 235, 60, 60))
      end
    end
  end
end
