require_relative "../test_helper"
require "digest"
require "json"
require "core/data_store"
require "game/item_catalog"
require "app/item_icons"

# S1 — the item catalog is DATA with teeth: every item validates at load,
# every id has a name in all three locales, every icon exists on the sheet
# and the sheet's bytes match the manifest md5 (art is replaceable, never
# accidental).
class ItemCatalogTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

  def catalog = @catalog ||= Game::ItemCatalog.load(DATA)

  def test_loads_every_item_with_kind_slot_and_numbers
    assert_operator catalog.size, :>=, 16
    catalog.each do |i|
      assert_includes catalog.kinds, i.kind
      assert i.slot.nil? || catalog.slots.include?(i.slot)
      assert i.price >= 0 && i.sell >= 0 && i.tier >= 0
      assert i.equipment? ^ i.stackable?, "#{i.id}: equipment never stacks, everything else does"
      assert (i.mods.keys - catalog.mod_keys).empty?
    end
    assert_equal 3, catalog.of_kind(:consumable).size
    assert catalog[:blade_iron].fits?(:striker)
    refute catalog[:blade_iron].fits?(:blocker)
    assert catalog[:jerkin_root].fits?(:lobber), "armor without fits fits everyone"
  end

  def test_every_item_is_named_in_every_locale
    %w[en es pt-br].each do |loc|
      strings = DATA["strings/#{loc}"]
      catalog.ids.each do |id|
        v = strings[:"item.#{id}.name"]
        assert v.is_a?(String) && !v.empty?, "#{loc}: item.#{id}.name missing"
      end
      catalog.kinds.each { |k| assert strings[:"item.kind.#{k}"], "#{loc}: item.kind.#{k} missing" }
    end
  end

  def test_icon_sheet_is_pinned_and_covers_the_catalog
    icons = App::ItemIcons.load(DATA)
    refute_nil icons, "data/art/items.json missing"
    assert File.file?(icons.path)
    assert_equal icons.md5, Digest::MD5.hexdigest(File.binread(icons.path)),
                 "items.png bytes != manifest md5 (regenerate: python tools/gen_item_icons.py)"
    catalog.each { |i| assert icons.include?(i.icon), "#{i.id}: icon #{i.icon} not on the sheet" }
  end

  def test_strict_loader_refuses_bad_data
    base = JSON.parse(JSON.generate(DATA["items"]), symbolize_names: true)
    bad = Marshal.load(Marshal.dump(base))
    bad[:items][:blade_iron][:mods] = { nope: 1 }
    assert_raises(Game::ItemCatalog::Invalid) { Game::ItemCatalog.new(bad) }
    bad = Marshal.load(Marshal.dump(base))
    bad[:items][:flask_sap][:slot] = "hand"
    assert_raises(Game::ItemCatalog::Invalid) { Game::ItemCatalog.new(bad) }
    bad = Marshal.load(Marshal.dump(base))
    bad[:items][:blade_iron].delete(:slot)
    assert_raises(Game::ItemCatalog::Invalid) { Game::ItemCatalog.new(bad) }
  end
end
