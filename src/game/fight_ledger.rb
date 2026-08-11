module Game
  # Sim-owned fight accounting (fight-ledger spec 2026-08-11): an engagement
  # window opens on combat or recovery, accrues the fight's loot movements,
  # and resolves after a quiet period into a registration beat the renderer
  # pure-reads. A leg accumulator reconciles at each banking. Clocks tick
  # only from tick_world, so hitstop and the wipe veil freeze them like
  # every D1 clock. MUST be constructed AFTER wire_events: World's
  # actor_died handler queues corpse_loaded/pack_wiped ahead of this
  # object's handlers in the same flush (the wipe-ordering pin).
  class FightLedger
    attr_reader :beat

    def initialize(bus, world:, config:)
      @bus = bus
      @world = world
      @quiet_frames = config[:ledger_quiet_frames]
      @beat_frames = config[:ledger_beat_frames]
      @window = nil
      @beat = nil
      @leg_gained = 0
      @leg_destroyed = 0
      wire
    end

    def tick
      if @beat
        @beat[:beat_left] -= 1
        @beat = nil unless @beat[:beat_left].positive?
      end
      return unless @window
      @window[:span] += 1
      @window[:quiet_left] -= 1
      resolve! if @window[:quiet_left] <= 0
    end

    private

    def wire
      @bus.subscribe(:damage_dealt) { open_or_refresh(:combat) }
      @bus.subscribe(:actor_died) do |e|
        open_or_refresh(:combat)
        if e[:faction] == :human
          @window[:kills] += 1
        else
          @window[:pack_deaths] += 1
        end
      end
      @bus.subscribe(:corpse_looted) do |e|
        open_or_refresh(:recovery)
        @window[:gained] += e[:amount]
      end
      @bus.subscribe(:drop_picked_up) do |e|
        @leg_gained += e[:amount] # leg counts FIRST acquisition, always
        next unless @window      # refreshes but NEVER opens (spec H3)
        @window[:quiet_left] = @quiet_frames
        @window[:gained] += e[:amount]
      end
      @bus.subscribe(:corpse_loaded) do |e|
        @window[:stranded] += e[:amount] if @window
      end
      @bus.subscribe(:carried_lost) do |e|
        @leg_destroyed += e[:amount] # at leg scale every expiry is a loss
        @window[:destroyed] += e[:amount] if @window && e[:zone] == @window[:zone]
      end
      @bus.subscribe(:pack_wiped) { resolve!(wiped: true) }
      @bus.subscribe(:zone_entered) { resolve! } # force-resolve on transition
      @bus.subscribe(:banked) { bank! }
    end

    def open_or_refresh(kind)
      if @window
        @window[:quiet_left] = @quiet_frames
      else
        # zone captured at OPEN — @zone_name is already the destination by
        # the time a transition's events flush (review M2-codefit).
        @window = { zone: @world.zone_name, opened_by: kind, span: 0,
                    quiet_left: @quiet_frames, gained: 0, stranded: 0,
                    destroyed: 0, kills: 0, pack_deaths: 0 }
      end
    end

    def resolve!(wiped: false)
      w = @window
      @window = nil
      return unless w
      qualifies = wiped || (w[:kills] + w[:pack_deaths]).positive? ||
                  (w[:gained] + w[:stranded] + w[:destroyed]).positive?
      return unless qualifies # dissolve — never stomps a live beat
      net = w[:gained] - w[:stranded] - w[:destroyed]
      @bus.emit(:fight_resolved, zone: w[:zone], span_frames: w[:span],
                opened_by: w[:opened_by], kills: w[:kills],
                pack_deaths: w[:pack_deaths], gained: w[:gained],
                stranded: w[:stranded], destroyed: w[:destroyed],
                net:, wiped:)
      # The WIPE recap's pip line is the FIELD truth (all live containers),
      # not this window's accrual (review M4-design). Its displayed net is
      # the field-truth net; the event payload keeps window semantics.
      pip = wiped ? @world.total_stranded : w[:stranded]
      @beat = { kind: wiped ? :wipe : :fight, gained: w[:gained],
                pip_amount: pip, dark_amount: w[:destroyed],
                net: w[:gained] - pip - w[:destroyed],
                recovery: w[:opened_by] == :recovery,
                beat_left: @beat_frames, beat_frames: @beat_frames }
    end

    def bank!
      @beat = { kind: :bank, gained: @leg_gained,
                pip_amount: @world.total_stranded, # outstanding, NOT in net
                dark_amount: @leg_destroyed,
                net: @leg_gained - @leg_destroyed, recovery: false,
                beat_left: @beat_frames, beat_frames: @beat_frames }
      @leg_gained = 0
      @leg_destroyed = 0
    end
  end
end
