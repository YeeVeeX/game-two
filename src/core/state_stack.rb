# Pushdown automata for game flow. Base states (e.g. :arena) sit at the bottom;
# overlays (e.g. :pause, :death) push on top. #current is the stack top.
#
# Hard transitions are validated against a transition table supplied at
# construction — an invalid transition raises (Kethral returned false silently,
# which let callers ignore failed transitions).
module Core
  class StateStack
    class InvalidTransition < StandardError; end

    attr_reader :previous

    def initialize(initial:, transitions:)
      @stack = [initial]
      @transitions = transitions
      @previous = nil
    end

    def current = @stack.last
    def depth = @stack.size
    def overlay? = @stack.size > 1
    def include?(state) = @stack.include?(state)

    # Hard transition: clears overlays, replaces the base state.
    def transition_to(new_state)
      allowed = @transitions.fetch(base, [])
      unless allowed.include?(new_state)
        raise InvalidTransition, "#{base} -> #{new_state} (allowed: #{allowed.inspect})"
      end
      @previous = current
      @stack = [new_state]
      new_state
    end

    # Overlay push/pop — not validated; caller ensures contextual sense.
    def push(overlay)
      @previous = current
      @stack.push(overlay)
    end

    def pop
      return current if @stack.size == 1
      @previous = @stack.pop
    end

    # The bottom state, ignoring overlays.
    def base = @stack.first
  end
end
