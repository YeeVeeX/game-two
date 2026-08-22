module Game
  # Digest-excluded cosmetic records shared with the renderer. World calls
  # the two clocks explicitly because combat records and banner records have
  # different pause laws; no bus or IO belongs in this plain object.
  class Transients
    attr_reader :taunt_pulses, :kill_pops, :seal_marks

    def initialize(pop_frames:)
      @pop_frames = pop_frames
      @taunt_pulses = []
      @kill_pops = []
      @seal_marks = []
    end

    def taunt_pulse!(tile:, pulse_frames:, range_tiles:)
      @taunt_pulses << { tile:, frames_left: pulse_frames,
                         pulse_frames:, range_tiles: }
    end

    def kill_pop!(tile:, frame:)
      @kill_pops << { tile:, frames_left: @pop_frames,
                      pop_frames: @pop_frames,
                      phase: (tile[0] * 31 + tile[1] * 17 + frame) % 997 }
    end

    def seal_mark!(at:, frames:)
      @seal_marks << { at:, frames_left: frames, frames_total: frames }
    end

    # Called only from tick_world: hitstop and the wipe veil pause combat
    # records exactly as they pause impacts.
    def tick_combat!
      age!(@taunt_pulses)
      age!(@kill_pops)
    end

    # Called from World's non-hitstop banner branch: hitstop pauses seal
    # marks, while the wipe veil does not.
    def tick_banner_clock!
      age!(@seal_marks)
    end

    def clear!
      @taunt_pulses.clear
      @kill_pops.clear
      @seal_marks.clear
    end

    private

    def age!(records)
      records.each { |record| record[:frames_left] -= 1 }
      records.reject! { |record| record[:frames_left] <= 0 }
    end
  end
end
