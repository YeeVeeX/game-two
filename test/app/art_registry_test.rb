require_relative "../test_helper"
require "digest"
require "core/data_store"
require "game/world"
require "app/art"

ART_DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))

# MUNDO VIVO FASE 1 — the art layer's contract, pinned without a GL
# context (Gosu images load lazily on first draw; nothing here opens a
# window). Real files only: the manifest and the committed atlases.
class ArtRegistryTest < Minitest::Test
  Fake = Struct.new(:facing, :attack_state, :moving, :dead, :hurt, :iframes, :kit_name) do
    def dead? = dead
    def hurt? = hurt
    def iframes? = iframes
    def moving? = moving
  end

  def registry = @registry ||= App::Art::Registry.load(ART_DATA)

  def test_manifest_loads_and_covers_every_combat_kit
    combat_kits = ART_DATA["balance/combat"][:kits].keys.map(&:to_sym).sort
    missing = combat_kits - registry.kits
    assert_empty missing, "kits without art (fallback quad would draw): #{missing.inspect}"
  end

  def test_every_atlas_exists_and_matches_its_manifest_grid_and_md5
    registry.kits.each do |kit|
      atlas = registry.atlas_for(kit)
      assert atlas.exists?, "#{kit}: atlas missing at #{atlas.path}"
      bytes = File.binread(atlas.path)
      # PNG IHDR: width/height at bytes 16..23 (big-endian) — the grid must
      # be exactly cols*frame_w x rows*frame_h or load_tiles slices garbage.
      w, h = bytes[16, 8].unpack("N2")
      assert_equal atlas.cols * registry.frame_w, w, "#{kit}: atlas width != cols*frame_w"
      assert_equal atlas.rows * registry.frame_h, h, "#{kit}: atlas height != rows*frame_h"
      assert_equal atlas.md5, Digest::MD5.hexdigest(bytes),
                   "#{kit}: atlas bytes drifted from the manifest md5 — regenerate with " \
                   "tools/gen_placeholder_art.py (art is replaceable; drift is not silent)"
    end
  end

  def test_every_anim_indexes_inside_the_grid
    registry.kits.each do |kit|
      atlas = registry.atlas_for(kit)
      %i[idle walk windup active hurt dead].each do |anim|
        fr = atlas.frames(anim)
        refute_empty fr, "#{kit}/#{anim}: no frames"
        assert fr.all? { |f| f.between?(0, atlas.cols - 1) }, "#{kit}/#{anim}: frame index outside cols"
        assert_operator atlas.frames_per_step(anim), :>=, 1
      end
    end
  end

  def test_facing_and_anim_selection_are_pure_and_cover_states
    b = App::Art::Body
    assert_equal "down", b.facing_name(Fake.new([0, 1], :idle, false, false, false, false, :striker))
    assert_equal "up", b.facing_name(Fake.new([0, -1], :idle, false, false, false, false, :striker))
    assert_equal "left", b.facing_name(Fake.new([-1, 0], :idle, false, false, false, false, :striker))
    assert_equal "right", b.facing_name(Fake.new([1, 0], :idle, false, false, false, false, :striker))
    assert_equal "down", b.facing_name(Fake.new([1, 1], :idle, false, false, false, false, :striker)),
                 "diagonal resolves to the vertical axis (notch keeps the 8-way truth)"
    assert_equal :dead, b.anim_for(Fake.new([1, 0], :idle, false, true, false, false, :striker))
    assert_equal :hurt, b.anim_for(Fake.new([1, 0], :idle, false, false, true, false, :striker))
    assert_equal :hurt, b.anim_for(Fake.new([1, 0], :idle, false, false, false, true, :striker))
    assert_equal :windup, b.anim_for(Fake.new([1, 0], :windup, true, false, false, false, :striker))
    assert_equal :active, b.anim_for(Fake.new([1, 0], :active, false, false, false, false, :striker))
    assert_equal :walk, b.anim_for(Fake.new([1, 0], :idle, true, false, false, false, :striker))
    assert_equal :idle, b.anim_for(Fake.new([1, 0], :idle, false, false, false, false, :striker))
  end

  def test_frame_col_is_deterministic_in_world_frame_and_stays_in_the_anim
    atlas = registry.atlas_for(:striker)
    walk = atlas.frames(:walk)
    200.times do |f|
      col = App::Art::Body.frame_col(atlas, :walk, f)
      assert_includes walk, col
      assert_equal col, App::Art::Body.frame_col(atlas, :walk, f), "same input, same frame"
    end
  end

  def test_missing_manifest_yields_an_empty_registry_not_a_crash
    reg = App::Art::Registry.new(nil, ART_DATA.root)
    assert_empty reg.kits
    assert_nil reg.atlas_for(:striker)
  end

  def test_data_store_exposes_its_root
    assert ART_DATA.root.directory?
  end
end
