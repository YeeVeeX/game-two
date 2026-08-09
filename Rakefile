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
