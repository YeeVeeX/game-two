require_relative "../test_helper"
require "json"

# T3: the three locale tables carry IDENTICAL key sets — every new
# player-visible key lands en/es/pt-br three-way or not at all (parity
# was only hand-verified before this test). Values may differ
# (functional verbs translate; placeholder names stay invariant); keys
# never do.
class StringsParityTest < Minitest::Test
  DIR = File.expand_path("../../data/strings", __dir__)

  def keys(locale) = JSON.parse(File.read(File.join(DIR, "#{locale}.json"))).keys.sort

  def test_locale_key_sets_are_identical
    en = keys("en")
    assert_equal en, keys("es"), "es.json key set must match en.json"
    assert_equal en, keys("pt-br"), "pt-br.json key set must match en.json"
  end
end
