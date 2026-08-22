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
    attr_reader :members, :mark, :banked, :provisions

    def initialize(members:, stagger_frames:, initial_kit: nil, seats: 1)
      @members = members
      @stagger_frames = stagger_frames
      @banked = 0
      # v18 decision 15: field charges bought at the bank for banked value
      # — pack state beside @banked, persisted (F1). Gameplay writes go
      # through the guarded buy_provision!/use_provision! verbs only.
      @provisions = 0
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

    # v17 digest lane (spec decision 6): banked, provisions, mark, and
    # the possession map as seat=>stable-id (nil while a seat waits).
    def digest_fields
      [["banked", @banked], ["provisions", @provisions], ["mark", @mark&.name]] +
        @possessed.map { |seat, body| ["possessed.#{seat}", body&.name] }
    end

    # v18 save-apply seam (SaveState.apply! only): provisions arrive
    # pre-clamped to the cap. Never a gameplay verb — the sustain verb
    # spends banked through its own guarded path.
    def load_provisions!(amount)
      @provisions = amount
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

    # v18 decision 9 buy (player-initiated at the bank via the sustain
    # press — banked reduces through spend!, the never-taxed law holds).
    # Guards return a refusal symbol and mutate NOTHING; nil = success.
    # Pure state: no bus, no world knowledge — numbers arrive from data
    # (Rule 3).
    def buy_provision!(cost:, cap:)
      return :at_cap if @provisions >= cap
      return :broke unless spend!(cost)
      @provisions += 1
      nil
    end

    # v18 decision 9 use: consumes ONE charge, heals every LIVING member
    # clamped at its ceiling — dead flesh untouched (the vat keeps its
    # regrowth monopoly). :none/:no_effect refuse BEFORE the charge is
    # eaten — a charge can never burn for nothing.
    def use_provision!(heal:)
      return :none if @provisions.zero?
      return :no_effect if living.none? { |m| m.hp < m.max_hp }
      @provisions -= 1
      living.each { |m| m.heal!(heal) }
      nil
    end

    # P4: idempotently align every body with the pack's current level.
    # Kit bases remain the source of truth; dead bodies gain only ceiling.
    def sync_max_hp!(progression:)
      @members.each do |member|
        target = progression.max_hp_for(member.kit[:max_hp])
        member.grow_max_hp!(target - member.max_hp)
      end
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
