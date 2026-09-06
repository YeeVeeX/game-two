module Game
  # S1 — the ITEM CATALOG (PREMIUM v22 systems proposal §1.1; owner YES s133,
  # sequenced after T1). Pure data from data/items.json: what an item IS —
  # kind, stack, slot, which kits it fits, price/sell, tier, family, the mods
  # it grants or the use it has. Names live in data/strings/*.json under
  # item.<id>.name (locale-at-render law; functional names, no fiction).
  #
  # Nothing here touches the sim yet: S2 (bag + drops) and S4 (equipment +
  # StatResolver) read this. Strict loader: an unknown kind / slot / mod key
  # or a stackable without a stack refuses at boot (data-driven, never a
  # constant in code; a typo is a boot error, not a silent 0).
  class ItemCatalog
    class Invalid < StandardError; end

    Item = Data.define(:id, :kind, :stack, :slot, :fits, :price, :sell, :tier, :family, :icon, :mods, :use) do
      def stackable? = stack > 1
      def equipment? = !slot.nil?
      def consumable? = kind == :consumable
      def material? = kind == :material
      def fits?(kit) = fits.nil? || fits.include?(kit.to_sym)
    end

    def self.load(data)
      new(data["items"])
    end

    attr_reader :kinds, :slots, :mod_keys

    def initialize(cfg)
      @kinds = cfg.fetch(:kinds).map(&:to_sym)
      @slots = cfg.fetch(:slots).map(&:to_sym)
      @mod_keys = cfg.fetch(:mod_keys).map(&:to_sym)
      @items = {}
      cfg.fetch(:items).each { |id, spec| @items[id.to_sym] = build(id.to_sym, spec) }
      @items.freeze
    end

    def [](id) = @items.fetch(id.to_sym) { raise Invalid, "unknown item #{id.inspect}" }
    def fetch(id, default = nil) = @items.fetch(id.to_sym, default)
    def include?(id) = @items.key?(id.to_sym)
    def ids = @items.keys
    def each(&) = @items.each_value(&)
    def of_kind(kind) = @items.values.select { |i| i.kind == kind.to_sym }
    def size = @items.size

    private

    def build(id, s)
      kind = s.fetch(:kind).to_sym
      raise Invalid, "#{id}: unknown kind #{kind}" unless @kinds.include?(kind)
      slot = s[:slot]&.to_sym
      raise Invalid, "#{id}: unknown slot #{slot}" if slot && !@slots.include?(slot)
      raise Invalid, "#{id}: #{kind} needs a slot" if %i[weapon armor trinket].include?(kind) && slot.nil?
      raise Invalid, "#{id}: #{kind} must not have a slot" if %i[consumable material].include?(kind) && slot
      stack = s.fetch(:stack, 1)
      raise Invalid, "#{id}: stack must be a positive Integer" unless stack.is_a?(Integer) && stack.positive?
      raise Invalid, "#{id}: equipment never stacks" if slot && stack != 1
      raise Invalid, "#{id}: consumables/materials stack (>1)" if %i[consumable material].include?(kind) && stack < 2
      %i[price sell tier].each do |k|
        v = s.fetch(k) { raise Invalid, "#{id}: missing #{k}" }
        raise Invalid, "#{id}: #{k} must be a non-negative Integer" unless v.is_a?(Integer) && v >= 0
      end
      mods = (s[:mods] || {}).transform_keys(&:to_sym)
      bad = mods.keys - @mod_keys
      raise Invalid, "#{id}: unknown mod keys #{bad.inspect}" unless bad.empty?
      raise Invalid, "#{id}: mods on a non-equipment" if !mods.empty? && slot.nil?
      use = s[:use]&.transform_keys(&:to_sym)
      raise Invalid, "#{id}: use on a non-consumable" if use && kind != :consumable
      raise Invalid, "#{id}: consumable needs a use" if kind == :consumable && use.nil?
      Item.new(id:, kind:, stack:, slot:, fits: s[:fits]&.map(&:to_sym), price: s[:price], sell: s[:sell],
               tier: s[:tier], family: s[:family]&.to_sym, icon: s.fetch(:icon).to_s, mods: mods.freeze,
               use: use&.freeze)
    end
  end
end
