# Central publish/subscribe hub. Systems hold a reference; they never call each other.
#
# Events are queued during the frame and flushed once via #process, so a handler
# can't cascade into another handler mid-frame. Events emitted during a flush are
# appended and handled in the same flush (FIFO).
#
# Unlike Kethral (80 event types defined upfront, most unused), events are
# registered explicitly when a system first needs one. Emitting or subscribing
# to an unregistered event raises — typos fail loudly at dev time.
require "set"

module Core
  class EventBus
    class UnknownEvent < StandardError; end

    Event = Data.define(:type, :payload) do
      def [](key) = payload[key]
    end

    def initialize
      @registered = Set.new
      @subscribers = Hash.new { |h, k| h[k] = [] }
      @queue = []
    end

    def register(*types)
      @registered.merge(types)
      self
    end

    def registered?(type) = @registered.include?(type)

    def subscribe(type, &callback)
      check!(type)
      @subscribers[type] << callback
      callback
    end

    def unsubscribe(type, callback)
      @subscribers[type].delete(callback)
    end

    def emit(type, **payload)
      check!(type)
      @queue << Event.new(type:, payload:)
    end

    # Flush the queue. Call once per frame after all updates.
    def process
      until @queue.empty?
        event = @queue.shift
        @subscribers[event.type].each { |cb| cb.call(event) }
      end
    end

    private

    def check!(type)
      raise UnknownEvent, "event #{type.inspect} not registered" unless @registered.include?(type)
    end
  end
end
