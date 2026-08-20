require_relative "../test_helper"
require "core/data_store"
require "core/strings"
require "core/binding_map"
require "core/input"
require "game/world"
require "app/renderer"
require "app/key_table"

# R-A2 (verdict row 4): the bank BUY hint — "U PROVISION -5" in the station
# cue's text slot, ONLY when the buy would succeed (banked >= cost AND
# provisions < cap), suppressed while a station cue lives on that bank tile
# (the transaction receipt owns the slot). Proximity stays at the draw site:
# the hint rides draw_station_ledger's radius-3 loop, same gate as the banked
# numeral. Content resolution is PURE (this lane); the walled gates prove the
# pixels. Zero new strings: glyph + ratified hud.provisions + the altar/vat
# "-price" grammar. Grill spec: drafts/_rA2-grill-spec-20260820.md.
class SustainHintTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  ECO = DATA["balance/economy"]
  BANK = DATA["zones/nest"][:stations].find { |s| s[:type] == "bank" }

  Held = Struct.new(:actions) do
    def down?(action) = actions.include?(action)
    def update(_frame) = nil
  end

  def renderer(locale: "en", bindings: :real)
    map = bindings == :real ? Core::BindingMap.load(DATA, key_table: App::KEY_TABLE, local: false) : bindings
    App::Renderer.new(display: DATA["display"],
                      strings: Core::Strings.new(DATA, locale: locale),
                      bindings: map)
  end

  def world = Game::World.new(DATA, seed: 7)

  def drive(w, n, inputs: Held.new([]))
    n.times { w.tick(inputs) }
  end

  # Stage through the PUBLIC verb only (sustain_test's stage_provisions!
  # precedent) — never load_provisions!.
  def buy!(w, n)
    home = w.possessed.tile
    w.possessed.walker.teleport(*BANK[:at])
    n.times do
      raise "staging: buy refused" unless w.sustain(w.possessed)
      drive(w, 1)
    end
    w.possessed.walker.teleport(*home)
  end

  def expire_cue!(w)
    drive(w, 1) until w.station_cue.nil?
  end

  def test_hint_speaks_exactly_when_a_buy_would_succeed
    w = world
    r = renderer
    assert_nil r.sustain_hint(w, BANK), "banked=0: broke — no hint (spawn frames byte-identical)"
    w.pack.bank!(50)
    assert_equal "U PROVISION -#{ECO[:provision_cost]}", r.sustain_hint(w, BANK),
                 "affordable + under cap: the hint teaches verb + price at the vendor"
    buy!(w, ECO[:provision_cap])
    expire_cue!(w)
    assert_nil r.sustain_hint(w, BANK), "at cap: a buy would refuse — never advertise a refusal"
  end

  def test_receipt_suppresses_the_hint_only_on_its_own_tile
    w = world
    r = renderer
    w.pack.bank!(50)
    w.possessed.walker.teleport(*BANK[:at])
    drive(w, 2, inputs: Held.new([:sustain])) # buy -> cue at the bank tile
    refute_nil w.station_cue
    assert_equal BANK[:at], w.station_cue[:at]
    assert_nil r.sustain_hint(w, BANK), "receipt owns the slot while it lives"
    expire_cue!(w)
    refute_nil r.sustain_hint(w, BANK), "hint returns when the receipt expires"
    # A cue elsewhere (stockless-use refusal at the body's own tile, off
    # bank) must NOT blank the bank's hint.
    w.possessed.walker.teleport(5, 5)
    w.pack.living.each(&:heal_full!)
    drive(w, 2, inputs: Held.new([:sustain])) # :no_effect -> cue at (5,5)
    refute_nil w.station_cue
    refute_equal BANK[:at], w.station_cue[:at]
    refute_nil r.sustain_hint(w, BANK), "an unrelated cue never blanks the hint"
  end

  def test_hint_is_bank_only_and_survives_bare_construction
    w = world
    w.pack.bank!(50)
    altar = DATA["zones/nest"][:stations].find { |s| s[:type] == "altar" }
    assert_nil renderer.sustain_hint(w, altar), "the hint is the BANK's voice only"
    bare = App::Renderer.new
    assert_equal "U PROVISION -#{ECO[:provision_cost]}", bare.sustain_hint(w, BANK),
                 "strings/bindings-less construct stays drawable (VESSEL_FALLBACK law)"
  end

  def test_locale_trio_translates_the_noun_only
    w = world
    w.pack.bank!(50)
    cost = ECO[:provision_cost]
    assert_equal "U PROVISIÓN -#{cost}", renderer(locale: "es").sustain_hint(w, BANK)
    assert_equal "U SUPRIMENTOS -#{cost}", renderer(locale: "pt-br").sustain_hint(w, BANK)
  end

  def test_world_exposes_the_data_driven_price_readers
    w = world
    assert_equal ECO[:provision_cost], w.provision_cost
    assert_equal ECO[:provision_cap], w.provision_cap
  end
end
