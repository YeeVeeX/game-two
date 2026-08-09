# Input abstraction — the seam that makes deterministic replay possible (Rule 2).
#
# Game code NEVER calls Gosu.button_down? directly. It asks an input source
# about abstract actions (:left, :right, :up, :down, :attack, :confirm).
# Live play feeds KeyboardInput; the replay harness feeds ScriptedInput, which
# reads a per-frame action script, so any bug or capture is reproducible.
module Core
  # Live keyboard, mapped to abstract actions. Gosu-facing (only queried, so
  # it stays testable: pass a fake `backend` responding to button_down?).
  class KeyboardInput
    def initialize(backend: nil, bindings:)
      @backend = backend
      @bindings = bindings # action symbol => [key codes]
    end

    def down?(action)
      @bindings.fetch(action, []).any? { |key| backend_down?(key) }
    end

    def update(_frame) = nil

    private

    def backend_down?(key)
      (@backend || Gosu).button_down?(key)
    end
  end

  # Replay script: { "frames": { "12": ["right", "attack"], ... } }
  # Frame numbers are the frame the actions are HELD on; contiguous runs are
  # expressed by listing each frame (scripts are generated, not hand-typed).
  class ScriptedInput
    def initialize(script)
      @frames = script.fetch(:frames, {}).to_h do |frame, actions|
        [Integer(frame.to_s), actions.map(&:to_sym)]
      end
      @current = []
    end

    def update(frame)
      @current = @frames.fetch(frame, [])
    end

    def down?(action) = @current.include?(action)

    def last_frame = @frames.keys.max || 0
  end
end
