module Game
  # The three creatures + the possession pointer. Possession is a pointer
  # move, never a state copy — exhaust/buffers stay creature-owned (law 4).
  class Pack
    attr_reader :members, :possessed

    def initialize(members:, stagger_frames:)
      @members = members
      @possessed = members.first
      @stagger_frames = stagger_frames
    end

    def living = @members.reject(&:dead?)
    def wipe? = living.empty?

    # Voluntary Tab swap: next living member in roster order, no stagger.
    def swap_next!
      order = @members.rotate(@members.index(@possessed) + 1)
      target = order.find { |m| !m.dead? && !m.equal?(@possessed) }
      return nil unless target
      @possessed = target
    end

    # Death swap: control snaps to the NEAREST living member (Chebyshev from
    # the dead body) and pays the stagger — losing a body costs a beat (law 2).
    def forced_swap!
      dead_at = @possessed.tile
      target = living.min_by do |m|
        [[(m.tile[0] - dead_at[0]).abs, (m.tile[1] - dead_at[1]).abs].max, @members.index(m)]
      end
      return nil unless target
      target.stagger!(@stagger_frames)
      @possessed = target
    end
  end
end
