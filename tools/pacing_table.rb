# STANDING SCRIPT — RUN ON EVERY CURVE/CAP TOUCH (v20 foundation L5:
# "the hours-per-level math is promoted to a standing script (run on
# every curve touch and every cap step)"). Output gets pasted into the
# touching ticket's drafts/ record — the table decides, the record
# explains.
#
# Blueprint: drafts/_v20-pacing-analysis-20260826.md — this tool is that
# doc's measured arithmetic, mechanized. Per level it emits ΔE(L)
# (= XP cost of going L−1 → L), cumulative E(L), minutes-per-step at the
# income-band edges, and kills-per-step per kill_xp kind; the footer
# carries the at-cap xp pin ΔE(cap+1) − 1 (projector-invariant law,
# src/game/progression.rb `award`).
#
# Zero balance constants live here: k, level_cap, and kill_xp are read
# LIVE from data/balance/progression.json through Core::DataStore, and
# ΔE comes from the real Game::Progression (formula identity with the
# sim — this tool cannot drift from the shipped curve). The default
# income-band columns (8000 / 20000 XP/sim-hour) are the pacing
# analysis §2 MEASURED band (three chain-verified human sessions,
# 2026-08-26) — dated measurements, not tunables; re-measure before
# leaning on them for a new band, and override via RATES= for what-ifs.
#
# Usage:
#   ruby tools/pacing_table.rb                      # table under the live file
#   CAP=12 ruby tools/pacing_table.rb               # price a candidate cap (raises
#                                                   #   only: lowering under a
#                                                   #   spell_growth threshold
#                                                   #   refuses, by design)
#   K=44 ruby tools/pacing_table.rb                 # full table under a candidate k
#   K_SWEEP=40,44,48 ruby tools/pacing_table.rb     # candidate-k dwell sweep over
#                                                   #   the top two steps to cap
#                                                   #   (the frontier dwell rows an
#                                                   #   L5-class target names)
#   RATES=8000,10916,20000 ruby tools/pacing_table.rb  # band columns (XP/sim-hour)
# Modes compose (e.g. CAP=12 K_SWEEP=40,44,48).

$LOAD_PATH.unshift File.expand_path("../src", __dir__)

require "core/data_store"
require "game/progression"

CONFIG = Core::DataStore.new(File.expand_path("../data", __dir__))["balance/progression"]

def build_progression(k: nil, cap: nil)
  curve = CONFIG[:curve]
  curve = curve.merge(k: Integer(k)) if k
  curve = curve.merge(level_cap: Integer(cap)) if cap
  Game::Progression.new(config: CONFIG.merge(curve:))
end

def minutes(delta_e, rate) = format("%.1f", delta_e * 60.0 / rate)

def print_table(rows)
  widths = rows.first.each_index.map { |i| rows.map { |r| r[i].length }.max }
  rows.each_with_index do |row, i|
    puts row.each_with_index.map { |cell, j| cell.rjust(widths[j]) }.join("  ")
    puts widths.map { |w| "-" * w }.join("--") if i.zero?
  end
end

rates = (ENV["RATES"] || "8000,20000").split(",").map { |r| Integer(r.strip, 10) }
prog = build_progression(k: ENV["K"], cap: ENV["CAP"])
cap = prog.level_cap
k = ENV["K"] ? Integer(ENV["K"]) : CONFIG[:curve][:k]
kill_xp = CONFIG[:kill_xp]

overrides = [("K=#{k}" if ENV["K"]), ("CAP=#{cap}" if ENV["CAP"])].compact
puts "pacing_table — k=#{k} cap=#{cap}" \
     "#{overrides.empty? ? ' (live data/balance/progression.json)' : " (override: #{overrides.join(', ')})"}"
puts "rates = #{rates.join(' / ')} XP/sim-hour (default = measured band, " \
     "drafts/_v20-pacing-analysis-20260826.md §2)"
puts "rows past the cap are extension arithmetic (marked +)"
puts

header = ["L", "dE(L)", "cumE(L)"] +
         rates.map { |r| "min@#{r}" } +
         kill_xp.keys.map { |kind| "#{kind}-kills" }
cum = 0
body = (2..(cap + 2)).map do |level|
  de = prog.delta_e(level)
  cum += de
  ["#{level}#{level > cap ? '+' : ''}", de.to_s, cum.to_s] +
    rates.map { |r| minutes(de, r) } +
    kill_xp.values.map { |xp| (de.to_f / xp).ceil.to_s }
end
print_table([header] + body)

cum_to_cap = (2..cap).sum { |l| prog.delta_e(l) }
pin = prog.delta_e(cap + 1) - 1
puts
puts "cum to cap: E(#{cap}) = #{cum_to_cap}"
puts "at-cap xp pin: dE(#{cap + 1}) - 1 = #{pin} (projector invariant — " \
     "award pins overflow xp just under the next ceiling)"

if (sweep = ENV["K_SWEEP"])
  ks = sweep.split(",").map { |v| Integer(v.strip, 10) }
  steps = [cap - 1, cap] # dE(cap-1) prices (cap-2)->(cap-1); dE(cap) prices (cap-1)->cap
  puts
  puts "candidate-k dwell sweep — top two steps to cap #{cap} " \
       "(v20 L5 target, owner-ratified s114: each new step ~15-30 min inside the band)"
  puts
  header = ["k"] +
           steps.flat_map { |l| ["dE(#{l - 1}->#{l})"] + rates.map { |r| "min@#{r}" } } +
           ["pin"]
  body = ks.map do |candidate|
    p = build_progression(k: candidate, cap: ENV["CAP"])
    [candidate.to_s] +
      steps.flat_map { |l| [p.delta_e(l).to_s] + rates.map { |r| minutes(p.delta_e(l), r) } } +
      [(p.delta_e(cap + 1) - 1).to_s]
  end
  print_table([header] + body)
end
