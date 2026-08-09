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
  else
    sh "python harness/vision_critic.py --verdict #{a_dir} --checks harness/gate_checks.json"
  end
  puts "GATE PASS"
end
