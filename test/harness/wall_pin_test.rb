require_relative "../test_helper"

# v18 decision 7i (W3, structural): the wall never touches persistence.
# Replay, harness scenes, and the pilot construct Worlds with save: nil
# (the default) and never write a save — a contaminated wall would turn
# every capture byte-comparison into noise. String-level pins on the
# harness sources (the line_caps_test precedent: enforced, not
# prompt-requested).
class WallPinTest < Minitest::Test
  HARNESS_SOURCES = Dir[File.expand_path("../../harness/**/*.rb", __dir__)].sort

  def test_harness_sources_exist
    assert_operator HARNESS_SOURCES.length, :>=, 8, "harness sources went missing"
  end

  def test_harness_never_references_persistence
    HARNESS_SOURCES.each do |path|
      src = File.read(path)
      %w[SaveStore SaveCoordinator persistence save_store backup_fresh].each do |token|
        refute_includes src, token,
                        "#{File.basename(path)} references #{token} — the wall " \
                        "constructs save: nil and never writes (decision 7i)"
      end
    end
  end

  def test_harness_world_constructions_never_pass_save
    HARNESS_SOURCES.each do |path|
      File.read(path).scan(/World\.new\([^)]*\)/m).each do |call|
        refute_match(/save:/, call,
                     "#{File.basename(path)}: #{call} — harness Worlds are save-blind")
      end
    end
  end
end
