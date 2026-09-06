require_relative "../test_helper"
require "json"

# v22 E3 b5 (T0 finding b5): every presentation knob is a WRITTEN row in
# data/display.json — never a `fetch(:k, default)` shadow in code (AGENTS
# non-negotiable 3: zero tunables in code; a renamed key must fail loud, not
# silently play a hidden default). Two laws, scanned over src/app/*.rb:
#   1. every `display.fetch(:k` key exists in data/display.json;
#   2. no `display.fetch(:k, default)` call survives.
# Exceptions need a `# display-optional:` comment ON the line and a row in
# OPTIONAL below (none today).
class DisplayKnobsTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  DISPLAY = JSON.parse(File.read(File.join(ROOT, "data/display.json")))
  SOURCES = Dir[File.join(ROOT, "src/app/*.rb")].sort
  OPTIONAL = [].freeze # "file.rb:key" rows allowed to carry a default (each line marked # display-optional:)

  def each_fetch
    SOURCES.each do |f|
      File.foreach(f).with_index(1) do |line, n|
        line.scan(/display\.fetch\(:(\w+)(,)?/) do |key, default|
          yield File.basename(f), n, key, !default.nil?, line
        end
      end
    end
  end

  def test_scan_sees_the_renderer_knobs
    keys = []
    each_fetch { |_f, _n, k, _d, _l| keys << k }
    assert_operator keys.uniq.size, :>=, 150, "scan regressed: #{keys.uniq.size} keys"
    assert_includes keys, "safe_chip_y"
  end

  def test_every_display_fetch_key_is_written_in_display_json
    missing = []
    each_fetch { |f, n, k, _d, _l| missing << "#{f}:#{n} #{k}" unless DISPLAY.key?(k) }
    assert_empty missing, "display.fetch keys missing from data/display.json:\n#{missing.join("\n")}"
  end

  def test_no_display_fetch_carries_a_code_default
    shadows = []
    each_fetch do |f, n, k, default, line|
      next unless default
      next if line.include?("# display-optional:") && OPTIONAL.include?("#{f}:#{k}")
      shadows << "#{f}:#{n} #{k}"
    end
    assert_empty shadows, "display.fetch calls still carry a code default (write the row, drop the default):\n#{shadows.join("\n")}"
  end

  def test_optional_rows_are_marked_on_their_line
    marked = []
    each_fetch { |f, _n, k, _d, line| marked << "#{f}:#{k}" if line.include?("# display-optional:") }
    assert_equal OPTIONAL.sort, marked.sort, "display-optional markers and OPTIONAL disagree"
  end
end
