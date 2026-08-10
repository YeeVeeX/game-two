require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test" << "src"
  t.pattern = "test/**/*_test.rb"
  t.warning = false
end

task default: :test

desc "Launch the game"
task :run do
  sh "ruby -Isrc src/main.rb"
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

desc "Rule 2 gate (BLOCKING): replay twice, byte-compare captures, vision verdict. SCRIPT=..."
task :gate do
  require "digest"
  require "json"
  require "fileutils"
  script = ENV.fetch("SCRIPT") { abort "Usage: rake gate SCRIPT=harness/scripts/<name>.json" }
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
    sh "python harness/vision_critic.py --verdict #{a_dir} --checks harness/gate_checks.json"
    puts "GATE PASS"
  end
end
