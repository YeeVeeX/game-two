require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test" << "src"
  t.pattern = "test/**/*_test.rb"
  t.warning = false
end

task default: :test

desc "God-view v0 (v18 decision 13): offline full-map PNG from data+save. [SAVE=path] [OUT=dir] [PROBES=1]"
task :map do
  sh "ruby -Isrc src/map_main.rb"
end

desc "Launch the game"
task :run do
  sh "ruby -Isrc src/main.rb"
end

desc "Wall pin ledger (v22 prep): per wall script, the last gate+manifest verdict and whether src/app, src/game or data/ moved since. Reads harness/pins.json (run_wall.sh writes it); never a gate."
task :pins do
  sh "ruby harness/pins.rb report"
end

desc "Deterministic replay + frame capture (Rule 2). SCRIPT=harness/scripts/<name>.json"
task :capture do
  script = ENV.fetch("SCRIPT") { abort "Usage: rake capture SCRIPT=harness/scripts/<name>.json" }
  sh "ruby -Isrc harness/replay_runner.rb #{script}"
end

desc "Interactive pilot session (file-driven). NAME=session SEED=0; see harness/pilot.rb header"
task :pilot do
  ENV["NAME"] ||= "session"
  ENV["SEED"] ||= "0"
  sh "ruby -Isrc harness/pilot.rb"
end

desc "Autonomous two-seat soak on a SCRATCH save (v18 session 8). N=episodes TICKS=min SEED=base; see soak/run_soak.sh header"
task :soak do
  # Bots are a test driver, never oracle evidence — the SEVENTEENTH's
  # arbiter reads human launcher logs only.
  sh "bash", "soak/run_soak.sh"
end

desc "Perf smoke (BLOCKING, machine-local): district scenario, abort if p95 tick >= 16.6ms"
task :perf do
  ruby_code = <<~'RUBY'
    require "core/data_store"
    require "core/input"
    require "game/world"
    require "benchmark"
    data = Core::DataStore.new("data")
    step = data["balance/combat"][:kits][:striker][:step_frames]
    w = Game::World.new(data)
    entry = (0...(step * 30)).to_h { |f| [f, [:right]] }
    input = Core::ScriptedInput.new(frames: entry)
    times = []
    (step * 30 + 6600).times do
      input.update(w.frame)
      t = Benchmark.realtime { w.tick(input) }
      times << t * 1000.0
    end
    sorted = times.sort
    p50 = sorted[times.length / 2]
    p95 = sorted[(times.length * 0.95).to_i]
    puts format("PERF ticks=%d p50=%.3fms p95=%.3fms max=%.3fms zone=%s",
                times.length, p50, p95, sorted.last, w.zone_name)
    abort format("PERF FAIL: p95 %.3fms >= 16.6ms budget", p95) if p95 >= 16.6
    puts "PERF PASS"
  RUBY
  sh "ruby", "-Isrc", "-e", ruby_code
end

desc "Manifest check (v15): script-declared event minimums vs a teed gate log. SCRIPT=... LOG=..."
task :manifest do
  script = ENV.fetch("SCRIPT") { abort "Usage: rake manifest SCRIPT=... LOG=..." }
  log = ENV.fetch("LOG") { abort "Usage: rake manifest SCRIPT=... LOG=..." }
  sh "ruby harness/manifest_check.rb #{script} #{log}"
end

desc "Stream canary (v15): ONE replay, per-frame md5 vs a preserved BASELINE dir. SCRIPT=... BASELINE=..."
task :canary do
  require "digest"
  require "json"
  require "fileutils"
  script = ENV.fetch("SCRIPT") { abort "Usage: rake canary SCRIPT=... BASELINE=..." }
  baseline = ENV.fetch("BASELINE") { abort "Usage: rake canary SCRIPT=... BASELINE=..." }
  abort "CANARY FAIL: baseline dir #{baseline} missing" unless Dir.exist?(baseline)
  out = "#{JSON.parse(File.read(script)).fetch('out_dir')}_canary"
  FileUtils.rm_rf(out)

  sh "ruby -Isrc harness/replay_runner.rb #{script} #{out}"

  ref = Dir[File.join(baseline, "*.png")].sort
  fresh = Dir[File.join(out, "*.png")].sort
  abort "CANARY FAIL: no captures produced" if fresh.empty?
  abort "CANARY FAIL: capture counts differ (#{fresh.size} vs baseline #{ref.size})" if fresh.size != ref.size
  ref.zip(fresh).each do |r, f|
    hr = Digest::MD5.file(r).hexdigest
    hf = Digest::MD5.file(f).hexdigest
    abort "CANARY FAIL: #{File.basename(f)} diverged from baseline (#{hf} != #{hr})" unless hr == hf
  end
  puts "CANARY PASS: #{fresh.size} captures byte-identical to #{baseline}"
end

desc "Rule 2 gate (BLOCKING): replay twice, byte-compare captures, vision verdict. SCRIPT=... [CHECKS=...]"
task :gate do
  require "digest"
  require "json"
  require "fileutils"
  script = ENV.fetch("SCRIPT") { abort "Usage: rake gate SCRIPT=harness/scripts/<name>.json" }
  # v17: netplay gates carry their OWN checks file (harness/net/
  # gate_checks.json) — the critic applies every check globally, so
  # world-conditioned checks would misfire on netplay frames (the
  # moving_square lesson). Default untouched: the wall stays the wall.
  checks = ENV.fetch("CHECKS", "harness/gate_checks.json")
  base = JSON.parse(File.read(script)).fetch("out_dir")
  a_dir = "#{base}_gate_a"
  b_dir = "#{base}_gate_b"
  [a_dir, b_dir].each { |d| FileUtils.rm_rf(d) }

  sh "ruby -Isrc harness/replay_runner.rb #{script} #{a_dir}"
  sh "ruby -Isrc harness/replay_runner.rb #{script} #{b_dir}"

  a_pngs = Dir[File.join(a_dir, "*.png")].sort
  b_pngs = Dir[File.join(b_dir, "*.png")].sort
  abort "GATE FAIL: no captures produced" if a_pngs.empty?
  abort "GATE FAIL: capture counts differ (#{a_pngs.size} vs #{b_pngs.size})" if a_pngs.size != b_pngs.size
  a_pngs.zip(b_pngs).each do |a, b|
    ha = Digest::MD5.file(a).hexdigest
    hb = Digest::MD5.file(b).hexdigest
    abort "GATE FAIL: nondeterministic capture #{File.basename(a)} (#{ha} != #{hb})" unless ha == hb
  end
  puts "GATE determinism: #{a_pngs.size} captures byte-identical across two runs"

  if ENV["SKIP_CRITIC"] == "1"
    puts "GATE vision: SKIPPED (SKIP_CRITIC=1 — determinism only, NOT a shippable pass)"
    puts "GATE PASS (determinism only)"
  else
    sh "python harness/vision_critic.py --verdict #{a_dir} --checks #{checks}"
    puts "GATE PASS"
  end
end
