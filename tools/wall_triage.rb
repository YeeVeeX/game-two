#!/usr/bin/env ruby
# Wall TRIAGE (headless, read-only, exit 0). Reads a wall sweep log (live
# harness/run_wall.sh output, or a banked drafts/_wall-*.log) and classifies
# every failing vision row against the HISTORY of earlier wall logs, so the
# flip-vs-real call stops living in one seat's memory:
#   NEW         first time this script/row fails -> re-gate first
#               (flip = passes the 2nd time; real = fails twice with the same phrase)
#   FLIP-PRONE  this script/row failed an earlier sweep and PASSED its re-gate there
#   DEBT        this script/row failed an earlier RE-GATE too (real bug, or a stale row)
#   REPEAT      failed an earlier sweep, no re-gate on record
# plus, per ROW across scripts: how often the row flipped anywhere (critic noise
# has a per-row signature: specials_distinct, kits_distinct, wipe_reads...).
#
#   ruby tools/wall_triage.rb <current_log> [previous_log ...]
#   ruby tools/wall_triage.rb ../game-two-wall6/tmp/wall/sweep_build4.log drafts/_wall-*.log
#
# Log grammar (run_wall.sh + tmp/_regate.sh): "=== WALL <s> HH:MM:SS ===" or
# "=== REGATE <s> HH:MM:SS ===" opens a block; "  [FAIL] <row>: <phrase>" and
# "MANIFEST FAIL: ..." belong to it; "=== <s> gate_rc=N [manifest_rc=M] ===" closes it.
# 2026-09-06, Junior's seat (wall #4 prep). Never runs a replay; re-gate is the
# seat's call: bash tmp/_regate.sh <scripts...> in the SAME worktree as the sweep.

def parse(path)
  blocks = []
  cur = nil
  File.foreach(path, encoding: "utf-8") do |raw|
    l = raw.chomp
    if (m = l.match(/\A=== (WALL|REGATE) (\S+) /))
      cur = { mode: m[1], script: m[2], rows: {}, gate_rc: nil, manifest_rc: nil, manifest_why: [] }
      blocks << cur
    elsif cur && (m = l.match(/\A=== #{Regexp.escape(cur[:script])} gate_rc=(\d+)(?: manifest_rc=(\d+))?/))
      cur[:gate_rc] = m[1].to_i
      cur[:manifest_rc] = m[2]&.to_i
      cur = nil
    elsif cur && (m = l.match(/\A\s*\[FAIL\] (\w+): (.*)/))
      cur[:rows][m[1]] = m[2].strip
    elsif cur && l =~ /INFRA/
      cur[:rows]["INFRA"] = l.strip[0, 110]
    elsif cur && (m = l.match(/\AMANIFEST FAIL:?\s*(.*)/))
      cur[:manifest_why] << m[1].strip[0, 110]
    end
  end
  blocks
end

current, *previous = ARGV
abort "usage: ruby tools/wall_triage.rb <current_log> [previous_log ...]" unless current

# --- history: per (script,row) and per row ---------------------------------------
hist = Hash.new { |h, k| h[k] = { sweep: 0, regate_pass: 0, regate_fail: 0, where: [] } }
row_flips = Hash.new { |h, k| h[k] = [] } # row -> ["script@log", ...] where a re-gate PASSED
previous.each do |p|
  tag = File.basename(p, ".log").sub(/\A_wall-/, "")
  bl = parse(p)
  sweep = bl.select { |b| b[:mode] == "WALL" }
  sweep.each { |b| b[:rows].each_key { |row| h = hist[[b[:script], row]]; h[:sweep] += 1; h[:where] << tag } }
  bl.select { |b| b[:mode] == "REGATE" }.each do |b|
    failed_rows = sweep.select { |s| s[:script] == b[:script] }.flat_map { |s| s[:rows].keys }.uniq
    failed_rows.each do |row|
      if b[:rows].key?(row)
        hist[[b[:script], row]][:regate_fail] += 1
      else
        hist[[b[:script], row]][:regate_pass] += 1
        row_flips[row] << "#{b[:script]}@#{tag}"
      end
    end
  end
end

def klass(h)
  return "NEW" if h.nil? || h[:sweep].zero?
  return "DEBT" if h[:regate_fail].positive?
  return "FLIP-PRONE" if h[:regate_pass].positive?
  "REPEAT"
end

# --- current log --------------------------------------------------------------------
blocks = parse(current)
sweep = blocks.select { |b| b[:mode] == "WALL" }
done = sweep.select { |b| b[:gate_rc] }
running = sweep.find { |b| b[:gate_rc].nil? }
gate_fails = done.select { |b| b[:gate_rc].positive? }
man_fails = done.select { |b| b[:manifest_rc]&.positive? }
puts "WALL #{current}: #{done.length} script(s) done#{running ? " (running: #{running[:script]})" : ""} · " \
     "gate fails #{gate_fails.length} · manifest fails #{man_fails.length} · history: #{previous.length} log(s)"
puts
fmt = "%-18s %-4s %-3s %-26s %-34s %s"
puts fmt % %w[script gate man row class phrase]
gate_fails.each do |b|
  b[:rows].each do |row, phrase|
    h = hist.key?([b[:script], row]) ? hist[[b[:script], row]] : nil
    k = klass(h)
    note = if k == "NEW" && row_flips[row].any?
             "NEW·row flipped #{row_flips[row].length}x"
           elsif h && h[:where].any?
             "#{k}(#{h[:where].uniq.join(',')})"
           else
             k
           end
    puts fmt % [b[:script], b[:gate_rc], b[:manifest_rc].to_s, row, note[0, 34], phrase[0, 60]]
  end
end
puts
puts "manifest fails: #{man_fails.map { |b| b[:script] }.join(' ')}" unless man_fails.empty?
man_fails.each { |b| b[:manifest_why].each { |w| puts "  #{b[:script]}: #{w}" } }
puts "suggested re-gate (same worktree): bash tmp/_regate.sh #{gate_fails.map { |b| b[:script] }.uniq.join(' ')}" unless gate_fails.empty?
unless row_flips.empty?
  puts "rows that flipped in history (critic noise signature): " +
       row_flips.sort_by { |_, v| -v.length }.first(8).map { |r, v| "#{r}(#{v.length})" }.join(" ")
end
