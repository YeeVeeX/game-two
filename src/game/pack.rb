module Game
  # The three creatures + the possession pointer. Possession is a pointer
  # move, never a state copy — exhaust/buffers stay creature-owned (law 4).
  class Pack
    attr_reader :members, :possessed, :mark, :banked

    def initialize(members:, stagger_frames:, initial_kit: nil)
      @members = members
      @possessed = members.find { |m| m.kit_name.to_s == initial_kit.to_s } || members.first
      @stagger_frames = stagger_frames
      @banked = 0
    end

    def living = @members.reject(&:dead?)
    def wipe? = living.empty?

    # v17 digest lane (spec decision 6): banked, mark, and the possession
    # map as seat=>stable-id. One seat today — increment 2 grows the map.
    def digest_fields
      [["banked", @banked], ["mark", @mark&.name], ["possessed.1", @possessed.name]]
    end

    def mark!(target)
      @mark = target
    end

    # Pack-owned and wipe-safe by construction: the Pack object is created
    # once (spawn_pack) and respawn_pack only revives members (law: banked
    # is NEVER taxed; in D0 it is not spent either — D1 adds the sinks).
    def bank!(amount)
      @banked += amount
    end

    # D1b sinks: the ONLY paths that reduce banked, all player-initiated at
    # stations (the never-taxed law holds — no system call sites exist).
    def spend!(amount)
      return false if amount > @banked
      @banked -= amount
      true
    end

    # Judgment-time pointer move (post-wipe possession snap): plain, no
    # stagger — revival is not a combat beat. Combat swaps keep using
    # swap_next!/forced_swap!.
    def possess!(target)
      @possessed = target
    end

    def clear_mark!
      @mark = nil
    end

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
