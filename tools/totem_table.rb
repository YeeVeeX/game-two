# STANDING SCRIPT — RUN ON EVERY TOTEM ROW TOUCH (v22 TS, s138; the
# tools/pacing_table.rb precedent: the table decides, the record explains).
# Output gets pasted into the touching ticket's drafts/ record.
#
# What it computes: the totem's heal throughput per body standing in the
# ring, OLD (the v20 T4 flat heal, hardcoded here as HISTORY because the
# rows no longer exist in data) vs the LIVE rows of
# data/balance/sustain.json, at every pack kit's real pool across levels —
# pools come from the real Game::Progression#max_hp_at (formula identity
# with the sim) and the kit bases from data/balance/combat.json; the potion
# economy from data/balance/economy.json. Zero balance constants live here
# except the v20 history row.
#
# Usage:
#   ruby tools/totem_table.rb                 # table under the live rows
#   PCT=8 MIN=15 CAD=180 ruby tools/totem_table.rb   # price a candidate
#   LEVELS=1,5,13,21 ruby tools/totem_table.rb       # level columns
#
# Floor/pct arithmetic (Integer, as the sim does it): heal =
# max(min, max_hp * pct / 100). The pct branch TIES the floor at
# max_hp = min*100/pct and first BEATS it at the smallest max_hp with
# max_hp*pct/100 >= min + 1 (a tie is not scaling — s138 review M1).

$LOAD_PATH.unshift File.expand_path("../src", __dir__)
require "core/data_store"
require "game/progression"

DATA = Core::DataStore.new(File.expand_path("../data", __dir__))
KITS = DATA["balance/combat"][:kits]
PROG = Game::Progression.new(config: DATA["balance/progression"])
ECO = DATA["balance/economy"]
LIVE = DATA["balance/sustain"][:totem]
# v20 T4 rows (2026-08-29 .. 2026-09-06), preserved for the comparison only.
V20_HISTORY = { cadence_ticks: 900, radius: 2, heal_amount: 10 }.freeze
PACK_KITS = %w[striker blocker lobber].freeze

pct = (ENV["PCT"] || LIVE[:heal_pct_max_hp]).to_i
min = (ENV["MIN"] || LIVE[:heal_min]).to_i
cad = (ENV["CAD"] || LIVE[:cadence_ticks]).to_i
levels = (ENV["LEVELS"] || "1,5,13,21").split(",").map(&:to_i)

def heal_for(max_hp, min, pct) = [min, (max_hp * pct) / 100].max
def hp_per_min(heal, cadence) = (heal * 3600) / cadence # 60 ticks per second, Integer
# Smallest pool at which the pct branch strictly beats the floor (nil = never
# below the sanity ceiling).
def first_beat(min, pct, ceiling: 10_000)
  return nil if pct.zero?
  (1..ceiling).find { |hp| (hp * pct) / 100 >= min + 1 }
end

puts "v20 totem (history): #{V20_HISTORY.inspect}"
puts "LIVE rows: #{LIVE.inspect}"
puts "TABLE under: cadence_ticks #{cad}, heal = max(#{min}, max_hp*#{pct}/100) Integer#{pct == LIVE[:heal_pct_max_hp] && min == LIVE[:heal_min] && cad == LIVE[:cadence_ticks] ? '' : '  (CANDIDATE, not the live rows)'}"
puts "Potion (economy.json): heal #{ECO[:provision_heal]} / cost #{ECO[:provision_cost]} / cap #{ECO[:provision_cap]}"
puts "Growth: hp_growth_pct #{DATA["balance/progression"][:growth][:hp_growth_pct]} per level; level_cap #{PROG.level_cap}"
puts
puts "| kit | L | max_hp | v20 heal/pulse | v20 hp/min | heal/pulse | hp/min | branch | pulses per potion | s in ring per potion |"
puts "|---|---|---|---|---|---|---|---|---|---|"
PACK_KITS.each do |k|
  base = KITS[k.to_sym][:max_hp]
  levels.each do |lv|
    mh = PROG.max_hp_at(lv, base)
    heal = heal_for(mh, min, pct)
    branch = (mh * pct) / 100 > min ? "pct" : ((mh * pct) / 100 == min ? "tie" : "floor")
    ppp = (ECO[:provision_heal] + heal - 1) / heal
    puts "| #{k} | #{lv} | #{mh} | #{V20_HISTORY[:heal_amount]} | #{hp_per_min(V20_HISTORY[:heal_amount], V20_HISTORY[:cadence_ticks])} | #{heal} | #{hp_per_min(heal, cad)} | #{branch} | #{ppp} | #{(ppp * cad) / 60} |"
  end
end
puts
puts "pct sweep — heal/pulse at L13 (the live save's level) and L#{PROG.level_cap} (cap), striker/blocker/lobber; 'beats from' = smallest max_hp where pct > floor:"
[4, 5, 6, 8, 10].each do |p|
  cells = [13, PROG.level_cap].map do |lv|
    PACK_KITS.map { |k| heal_for(PROG.max_hp_at(lv, KITS[k.to_sym][:max_hp]), min, p) }.join("/")
  end
  fb = first_beat(min, p)
  puts "  pct #{p}: L13 #{cells[0]}  L#{PROG.level_cap} #{cells[1]}  (beats the #{min} floor from max_hp #{fb || 'never'})"
end
puts
disp = JSON.parse(File.read(File.expand_path("../data/display.json", __dir__)))
puts "Ring: totem_pulse_frames #{disp["totem_pulse_frames"]} of cadence #{cad} ticks = #{(disp["totem_pulse_frames"] * 100) / cad}% duty, one beat every #{cad / 60.0} s"
