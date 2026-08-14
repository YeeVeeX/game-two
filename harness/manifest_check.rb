# Machine manifest check (v15, Codex fold): a staged script's teed gate
# log MUST show its declared events — a missing staged beat is a semantic
# desync even when the vision critic passes (four v14 re-pilots proved it;
# the critic passed three of the four). The manifest lives IN the script
# JSON (`"manifest": {event -> min count per DOUBLE replay}`); the wall
# procedure runs `rake manifest SCRIPT=... LOG=<teed log>` after every gate.
#
# Exit 0 = satisfied, or the script declares no manifest (SKIP, printed —
# moving_square/critic_reel are det-only by law). Exit 1 = shortfall, each
# missing event named. Log format pinned by world_scene.rb:
# "EVENT <name> frame=N ...".
require "json"

module Harness
  module ManifestCheck
    def self.run(script_path, log_path)
      script = JSON.parse(File.read(script_path))
      manifest = script["manifest"]
      return [:skip, "script declares no manifest (det-only law)"] unless manifest
      log = File.read(log_path, encoding: "UTF-8")
      counts = Hash.new(0)
      log.scan(/^EVENT (\w+) frame=/) { |(ev)| counts[ev] += 1 }
      failures = manifest.reject { |ev, min| counts[ev] >= min }
                         .map { |ev, min| "#{ev}: want >=#{min} per double replay, got #{counts[ev]}" }
      if failures.empty?
        [:pass, manifest.keys.map { |ev| "#{ev}=#{counts[ev]}" }.join(" ")]
      else
        [:fail, failures]
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  status, detail = Harness::ManifestCheck.run(ARGV.fetch(0), ARGV.fetch(1))
  case status
  when :skip
    puts "MANIFEST SKIP: #{detail}"
  when :pass
    puts "MANIFEST PASS: #{detail}"
  when :fail
    detail.each { |f| puts "MANIFEST FAIL: #{f}" }
    exit 1
  end
end
