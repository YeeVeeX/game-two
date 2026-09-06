# Schema-3 (v22 T1) save-facts builder for the peripheral suites that need
# a LEGAL loaded world (doors, gates, transitions, the map artifact) without
# caring about the save vocabulary itself. The host character is keyed
# "bot-1" = Game::Party.default_players' seat-1 id, so a World constructed
# without `players:` SEATS it. save_state_test owns the vocabulary law;
# this helper only mirrors the shape (Character.refusal judges it anyway).
module Schema3Facts
  HOST = "bot-1".freeze

  # `hp`: Integer for every kit, or kit-name(String) -> Integer.
  def self.record(roster, level: 1, xp: 0, home: "nest", hp: 1, form: nil, inscribed: [])
    kits = roster.map(&:to_s)
    {
      "level" => level, "xp" => xp, "xp_debt" => 0, "insurance" => 0,
      "home_zone" => home, "form" => (form || kits.first).to_s,
      "forms" => kits.to_h do |kit|
        [kit, { "hp" => hp.is_a?(Hash) ? hp.fetch(kit) : hp,
                "inscribed" => inscribed.map(&:to_s).include?(kit) }]
      end,
      "bag" => [], "equipment" => {}, "attributes" => {}, "bank_items" => []
    }
  end

  def self.facts(roster, banked: 0, provisions: 0, breached: [], defeats: 0, sessions: 0,
                 host: HOST, **record_kw)
    {
      "banked" => banked, "provisions" => provisions, "breached" => breached,
      "counters" => { "boss_1_defeats" => defeats, "sessions" => sessions },
      "characters" => { host => record(roster, **record_kw) }
    }
  end
end
