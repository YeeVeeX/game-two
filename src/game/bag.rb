module Game
  # S2 — the BAG (PREMIUM v22 systems proposal §2). One per pack: `slots`
  # stacks of {id, qty}; a stack holds up to the catalog's `stack` for that
  # item (equipment never stacks). Smart by default: `add!` fills existing
  # stacks first, then opens new slots; `sorted` is the display order —
  # consumables first, then weapons / armor / trinkets, materials last, by
  # tier then id — with the player's pinned ids floating to the top.
  #
  # SIM state: the contents are digested (both seats must agree on what you
  # hold). Persistence rides the schema-3 player record (T1) as one key,
  # `bag`, in the CANONICAL form `to_save` / `from_save` below. Zero constants: `slots` comes from economy.json
  # `bag_slots`; stack sizes from the catalog.
  class Bag
    KIND_ORDER = %i[consumable weapon armor trinket material].freeze

    attr_reader :slots

    def initialize(catalog:, slots:)
      @catalog = catalog
      @slots = slots
      @stacks = []   # [{ id: Symbol, qty: Integer }, ...] in insertion order
      @pinned = []
    end

    def stacks = @stacks.map(&:dup)
    def used = @stacks.length
    def free_slots = @slots - @stacks.length
    def empty? = @stacks.empty?
    def count(id) = @stacks.select { |s| s[:id] == id.to_sym }.sum { |s| s[:qty] }
    def include?(id) = count(id).positive?

    # true when at least `qty` more of `id` fit (existing stack room + free slots).
    def room_for?(id, qty = 1)
      item = @catalog[id]
      room = @stacks.select { |s| s[:id] == item.id }.sum { |s| item.stack - s[:qty] }
      room + free_slots * item.stack >= qty
    end

    # Adds up to qty; returns the OVERFLOW (0 when everything fit). Fills
    # partial stacks first, then new slots. Never raises on a full bag.
    def add!(id, qty = 1)
      item = @catalog[id]
      left = qty
      @stacks.each do |s|
        next unless s[:id] == item.id && s[:qty] < item.stack
        take = [item.stack - s[:qty], left].min
        s[:qty] += take
        left -= take
        break if left.zero?
      end
      while left.positive? && free_slots.positive?
        take = [item.stack, left].min
        @stacks << { id: item.id, qty: take }
        left -= take
      end
      left
    end

    # Removes up to qty from the LAST stacks first (so a full stack stays
    # full for as long as possible); returns what was actually removed.
    def remove!(id, qty = 1)
      sym = id.to_sym
      left = qty
      @stacks.reverse_each do |s|
        next unless s[:id] == sym
        take = [s[:qty], left].min
        s[:qty] -= take
        left -= take
        break if left.zero?
      end
      @stacks.reject! { |s| s[:qty].zero? }
      qty - left
    end

    def pin!(id) = (@pinned << id.to_sym unless @pinned.include?(id.to_sym))
    def unpin!(id) = @pinned.delete(id.to_sym)
    def pinned?(id) = @pinned.include?(id.to_sym)

    # Display order (the "smart bag"): pinned ids first (in pin order), then
    # by kind (consumables → materials), tier, id, qty desc.
    def sorted
      @stacks.sort_by do |s|
        item = @catalog[s[:id]]
        pin = @pinned.index(s[:id])
        [pin.nil? ? 1 : 0, pin || 0, KIND_ORDER.index(item.kind) || 99, item.tier, item.id.to_s, -s[:qty]]
      end.map(&:dup)
    end

    # Digest (lockstep): canonical, order-independent — the same contents in
    # any slot order produce the same string.
    def digest_string
      @stacks.group_by { |s| s[:id] }.map { |id, ss| "#{id}:#{ss.sum { |s| s[:qty] }}" }.sort.join("|")
    end

    def digest_fields = [["slots", @slots], ["used", used], ["contents", digest_string]]

    # --- persistence (T1 schema-3 player record, key `bag`; spec §T1: default `[]`) ---
    # CANONICAL form, same law as the digest: one entry per item id, quantities
    # merged, sorted by id, string keys (JSON). Slot layout is NOT saved - the
    # display order is `sorted` (derived), so two saves of the same contents are
    # byte-identical whatever order the stacks were picked up in.
    def to_save
      @stacks.group_by { |s| s[:id] }.map { |id, ss| { "id" => id.to_s, "qty" => ss.sum { |s| s[:qty] } } }
             .sort_by { |h| h["id"] }
    end

    # STRICT loader (character-validator law, spec §T1): a list that is not an
    # Array of {"id" => String, "qty" => positive Integer} with catalog ids, or that
    # does not FIT the bag, raises ArgumentError - never a phantom or truncated stack.
    # The validator owns the failure mode (refuse the record); this only tells the truth.
    def self.from_save(list, catalog:, slots:)
      raise ArgumentError, "bag: expected an Array, got #{list.class}" unless list.is_a?(Array)
      b = new(catalog:, slots:)
      seen = []
      list.each do |h|
        ok = h.is_a?(Hash) && h["id"].is_a?(String) && h["qty"].is_a?(Integer) && h["qty"].positive?
        raise ArgumentError, "bag: bad entry #{h.inspect}" unless ok
        id = h["id"].to_sym
        raise ArgumentError, "bag: unknown item #{h['id'].inspect}" unless catalog.include?(id)
        raise ArgumentError, "bag: duplicate id #{h['id'].inspect} (canonical form merges)" if seen.include?(id)
        seen << id
        raise ArgumentError, "bag: #{h['qty']} x #{h['id']} does not fit #{slots} slots" unless b.room_for?(id, h["qty"])
        b.add!(id, h["qty"])
      end
      b
    end
  end
end
