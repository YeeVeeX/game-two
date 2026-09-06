require "game/bag"
require "game/item_catalog"

module Game
  # S2 — LOOT (mixed into World): the item catalog, the pack's bag, the per-
  # kit drop tables and the :loot RNG stream. Extracted so world.rb stays
  # under its growth ceiling (test/app/line_caps_test.rb). Every rule is
  # data: economy.json bag_slots / item_drop_frames, balance/drops.json.
  #
  # Stream law: item rolls draw ONLY from @loot_rng (its own seed salt), so
  # the combat and respawn streams keep their draw counts byte-for-byte —
  # the existing canaries do not move when a kit gains a drop table.
  module Loot
    LOOT_STREAM_SALT = 0x4c4f4f54

    def init_loot!(data, seed)
      @loot_rng = Core::CountingRng.new(Random.new(seed ^ LOOT_STREAM_SALT))
      @catalog = Game::ItemCatalog.load(data)
      @bag = Game::Bag.new(catalog: @catalog, slots: @economy.fetch(:bag_slots))
      @drop_tables = (data["balance/drops"][:tables] || {}).transform_keys(&:to_sym)
    end

    # Hostiles only; the field owns the records (per zone, digested).
    def roll_item_drops(actor)
      return unless actor.faction == :human
      @field.spawn_item_drops(actor, zone: @zone_name, table: @drop_tables[actor.kit_name],
                              rng: @loot_rng, decay: @economy.fetch(:item_drop_frames))
    end

    # Interact on a tile with an item: to the bag. A full bag refuses (named
    # event; the item stays). Returns true/false, or nil when there was no
    # item here (the caller continues to stations).
    def pick_up_item(source)
      idrop = item_drops.find { |d| d[:tile] == source.tile }
      return nil unless idrop
      unless @bag.room_for?(idrop[:id], idrop[:qty])
        @bus.emit(:bag_full, actor: source, item: idrop[:id])
        return false
      end
      item_drops.delete(idrop)
      @bag.add!(idrop[:id], idrop[:qty])
      @bus.emit(:item_picked_up, actor: source, item: idrop[:id], qty: idrop[:qty])
      true
    end

    # S3: the first bag consumable whose use.cure names a status this body
    # carries - removes one, cures, emits item_used. false when none applies.
    def use_cure_item(source)
      source.statuses.each do |st|
        # canonical id order: a UI pin must never steer the sim (review MINOR 7)
        item = @bag.stacks.map { |k| k[:id] }.uniq.sort.map { |id| @catalog.fetch(id) }.compact.find do |i|
          i.consumable? && Array(i.use&.dig(:cure)).map(&:to_sym).include?(st)
        end
        next unless item
        @bag.remove!(item.id, 1)
        source.cure!(st)
        @bus.emit(:item_used, actor: source, item: item.id, status: st)
        return true
      end
      false
    end
  end
end
