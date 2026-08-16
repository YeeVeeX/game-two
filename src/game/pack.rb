module Game
  # The three creatures + the possession pointers. Possession is a pointer
  # move, never a state copy — exhaust/buffers stay creature-owned (law 4).
  #
  # v17 seat map (spec Sim spec): one pointer PER SEAT, seat ids pinned
  # [1..n]. Bare arity everywhere = seat 1, so every existing call site
  # behaves exactly as before. A nil pointer = that seat is WAITING FOR
  # BODY (decision 3: partner holds the last living flesh). No two seats
  # ever hold the same body — swap/forced-swap exclude partner bodies.
  class Pack
    attr_reader :members, :mark, :banked

    def initialize(members:, stagger_frames:, initial_kit: nil, seats: 1)
      @members = members
      @stagger_frames = stagger_frames
      @banked = 0
      first = members.find { |m| m.kit_name.to_s == initial_kit.to_s } || members.first
      @possessed = { 1 => first }
      (2..seats).each do |seat|
        @possessed[seat] = members.find { |m| !m.dead? && !held?(m) }
      end
    end

    def seats = @possessed.keys
    def possessed(seat = 1) = @possessed[seat]

    def living = @members.reject(&:dead?)
    def wipe? = living.empty?

    # v17 digest lane (spec decision 6): banked, mark, and the possession
    # map as seat=>stable-id (nil while a seat waits for a body).
    def digest_fields
      [["banked", @banked], ["mark", @mark&.name]] +
        @possessed.map { |seat, body| ["possessed.#{seat}", body&.name] }
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
    # swap_next!/forced_swap!. nil = the seat enters waiting-for-body.
    def possess!(target, seat: 1)
      @possessed[seat] = target
    end

    def clear_mark!
      @mark = nil
    end

    # The body a voluntary Tab would land on: next living member in roster
    # order, skipping the partner's body (decision 3). nil = Tab refused.
    # Single-seat: exists iff a second living body exists — the old law.
    def swap_target(seat = 1)
      current = @possessed.fetch(seat)
      order = @members.rotate(@members.index(current) + 1)
      order.find { |m| !m.dead? && !m.equal?(current) && !held_by_partner?(m, seat) }
    end

    # Voluntary Tab swap: no stagger.
    def swap_next!(seat = 1)
      target = swap_target(seat)
      return nil unless target
      @possessed[seat] = target
    end

    # Death swap: control snaps to the NEAREST living member (Chebyshev from
    # the dead body) and pays the stagger — losing a body costs a beat
    # (law 2). The partner's body is EXCLUDED (decision 3); when no free
    # body exists and the pack still lives, the seat enters WAITING FOR
    # BODY (pointer nil). On a full wipe the pointer stays on the dead
    # body — the judgment reads the wipe vessel from it.
    def forced_swap!(seat = 1)
      dead_at = @possessed.fetch(seat).tile
      target = living.reject { |m| held_by_partner?(m, seat) }.min_by do |m|
        [[(m.tile[0] - dead_at[0]).abs, (m.tile[1] - dead_at[1]).abs].max, @members.index(m)]
      end
      if target
        target.stagger!(@stagger_frames)
        @possessed[seat] = target
      elsif !wipe?
        @possessed[seat] = nil
      end
      target
    end

    private

    def held?(body) = @possessed.values.any? { |b| b&.equal?(body) }

    def held_by_partner?(body, seat)
      @possessed.any? { |s, b| s != seat && b&.equal?(body) }
    end
  end
end
