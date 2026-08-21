require "json"

# v18 session-8 soak (brief D6/D7): judge a soak run from LOGS + exit
# codes ONLY — never process liveness (memorized law: an idle seat sits
# at ticks=0 and a dead session holds its end screen; only TELEMETRY
# lines tell the truth). Lives in soak/, NEVER harness/ (wall_pin_test
# bans persistence tokens there — the wall stays single-player).
#
# The invariants are Half-A-SHAPED rehearsals on SCRATCH data: both
# seats reason=quit, desyncs=0, ticks >= target, host loaded digest ==
# previous saved digest, sessions +1 per episode, joiner handshake
# digest == host's. The spec's arbiter stays CLOSED (human sessions
# only) — a soak verdict is NEVER oracle evidence for the SEVENTEENTH.
module Soak
  module ChainCheck
    NETPLAY = /^TELEMETRY netplay seat=(\d+) ticks=(\d+) desyncs=(\d+) stalls=\d+ stall_ms_max=\d+ reason=(\w+)/
    PERSIST = /^TELEMETRY persist (fresh|loaded|saved)(?: digest=(\h{32}))?(?: schema=\d+ banked=\d+ provisions=\d+ seals=\d+ marks=\d+)?(?: sessions=(\d+))?(?: source=(\w+))?/
    BANNER = /^AUTOPILOT seed=(\d+) quit_tick=(\d+)/
    START_ZONE = /^START_ZONE zone=(\S+)/
    FIGHTS = /^TELEMETRY d1_fired .*\bfights=(\d+)/
    # Coverage law (lane 1, 2026-08-19): hub zones are combat-exempt —
    # their spawns sit far from pack_spawn by design. T5 (2026-08-21,
    # T4-review defect 2 closed): DERIVED from data/zones/*.json hub
    # flags — the hand list was drifting toward a third entry, so the
    # data owns it now (nest · camp · zone_7 today; pinned by test).
    HUB_ZONES = Dir[File.expand_path("../data/zones/*.json", __dir__)]
                .select { |p| JSON.parse(File.read(p))["hub"] == true }
                .map { |p| File.basename(p, ".json") }.sort.freeze

    module_function

    # episodes: [{index:, host_log:, joiner_log:, host_exit:, joiner_exit:,
    # timeout:}, ...] (logs/exits nil when absent). -> [pass, report_lines]
    # seed_digest: a pre-seeded scratch chain (soak/seed_save.rb) — ep1
    # must LOAD it (a fresh ep1 = the seed never applied, named).
    # zones: per-episode start-zone cycle (episode i gets zones[(i-1) %
    # len]); each zoned episode must show START_ZONE on BOTH present
    # seats, and non-hub zones must show combat (fights > 0).
    def check(episodes, min_ticks:, mode: "both", allow_link_faults: false,
              seed_digest: nil, zones: nil)
      lines = ["SOAK CHECK mode=#{mode} min_ticks=#{min_ticks} episodes=#{episodes.length}" \
               "#{seed_digest ? " seeded=#{seed_digest[0, 8]}" : ''}" \
               "#{zones && !zones.empty? ? " zones=#{zones.join(',')}" : ''}"]
      failures = 0
      chain = if seed_digest
                { last_saved: seed_digest, last_sessions: 0,
                  links: ["seeded:#{seed_digest[0, 8]}"], seeded: true }
              else
                { last_saved: nil, last_sessions: 0, links: ["fresh"] }
              end
      zone_cycle = zones && !zones.empty? ? zones : nil
      sides = { "both" => %i[host joiner], "host_only" => [:host], "join_only" => [:joiner] }
              .fetch(mode)
      episodes.each do |ep|
        fails = []
        link_fault = false
        %i[host joiner].each do |side|
          unless sides.include?(side)
            lines << "EP#{ep[:index]} SKIP #{side} (#{mode} run)"
            next
          end
          log = ep[:"#{side}_log"]
          exit_code = ep[:"#{side}_exit"]
          if log.nil?
            fails << "#{side} log missing"
            next
          end
          seat = parse_seat(log, side)
          lines << "EP#{ep[:index]} #{side}: seed=#{seat[:seed] || '?'} " \
                   "ticks=#{seat[:ticks] || '?'} desyncs=#{seat[:desyncs] || '?'} " \
                   "reason=#{seat[:reason] || '?'} exit=#{exit_code.inspect}"
          fails << "#{side} missing AUTOPILOT banner (bot did not drive)" unless seat[:seed]
          fails << "#{side} persist ERROR line: #{seat[:persist_error]}" if seat[:persist_error]
          unless seat[:ticks]
            fails << "#{side} has no TELEMETRY netplay line"
            next
          end
          fails << "#{side} desyncs=#{seat[:desyncs]} (hard fail, always)" if seat[:desyncs].positive?
          fails << "#{side} wrong seat=#{seat[:seat]}" if seat[:seat] != (side == :host ? 1 : 2)
          if exit_code == 2 && allow_link_faults
            link_fault = true
            lines << "FINDING: EP#{ep[:index]} #{side} link fault (conn_lost, exit 2) — " \
                     "rejoin behavior recorded; chain expects the last saved digest"
          elsif exit_code != 0
            fails << "#{side} exit=#{exit_code.inspect} (want 0)"
          elsif seat[:reason] != "quit"
            fails << "#{side} reason=#{seat[:reason]} (want quit)"
          elsif seat[:ticks] < min_ticks
            fails << "#{side} ticks=#{seat[:ticks]} < #{min_ticks}"
          end
        end
        fails << "timeout — seats killed by the orchestrator" if ep[:timeout]
        check_zone(ep, zone_cycle, lines, fails, sides) if zone_cycle
        check_persistence(ep, chain, lines, fails, sides, link_fault:)
        if fails.empty?
          lines << "EP#{ep[:index]} PASS"
        else
          failures += 1
          lines << "EP#{ep[:index]} FAIL: #{fails.join('; ')}"
        end
      end
      if sides.include?(:host) && failures.zero?
        lines << "CHAIN intact: #{chain[:links].join(' -> ')}, " \
                 "sessions #{chain[:first_sessions] || 1}->#{chain[:last_sessions]}"
      end
      pass = failures.zero?
      lines << (pass ? "SOAK PASS episodes=#{episodes.length}" :
                       "SOAK FAIL episodes=#{episodes.length} failed=#{failures}")
      [pass, lines]
    end

    # Lane 1 coverage: the zoned episode must PROVE it started there (both
    # seats print START_ZONE) and, outside hubs, that combat actually ran.
    def check_zone(ep, zones, lines, fails, sides)
      zone = zones[(ep[:index] - 1) % zones.length]
      lines << "EP#{ep[:index]} zone=#{zone}"
      %i[host joiner].each do |side|
        next unless sides.include?(side)
        log = ep[:"#{side}_log"]
        next if log.nil? # already failed above
        got = log[START_ZONE, 1]
        if got != zone
          fails << "#{side} START_ZONE #{got ? "zone=#{got}" : 'line missing'} " \
                   "(expected zone=#{zone})"
        end
      end
      return if HUB_ZONES.include?(zone)
      return if ep[:host_log].nil? || !sides.include?(:host)
      fights = ep[:host_log][FIGHTS, 1].to_i
      fails << "no combat in #{zone} (fights=#{fights}) — coverage episode " \
               "must exercise the sim, not idle" unless fights.positive?
    end

    # The persistence chain lives host-side (the joiner never persists —
    # F2). join_only runs skip it entirely, named.
    def check_persistence(ep, chain, lines, fails, sides, link_fault:)
      unless sides.include?(:host)
        lines << "EP#{ep[:index]} SKIP host persistence (joiner never persists)"
        return
      end
      log = ep[:host_log]
      return if log.nil? # already failed above
      persists = log.scan(PERSIST).map do |kind, digest, sessions, source|
        { kind:, digest:, sessions: sessions&.to_i, source: }
      end
      loaded = persists.find { |p| p[:kind] == "loaded" }
      saved = persists.reverse.find { |p| p[:kind] == "saved" }
      fresh = persists.any? { |p| p[:kind] == "fresh" }
      if chain[:last_saved].nil?
        fails << "expected a fresh start (scratch save), got none" unless fresh || loaded
        fails << "loaded #{loaded[:digest]} but no prior save exists" if loaded
      elsif loaded.nil?
        fails << if chain[:seeded] && chain[:links].length == 1
                   "episode 1 did not load the seeded save (expected #{chain[:last_saved]})"
                 else
                   "no persist loaded line (previous saved digest #{chain[:last_saved]})"
                 end
      elsif loaded[:digest] != chain[:last_saved]
        fails << if chain[:seeded] && chain[:links].length == 1
                   "episode 1 did not load the seeded save: loaded #{loaded[:digest]} " \
                   "!= seeded #{chain[:last_saved]}"
                 else
                   "chain break: loaded #{loaded[:digest]} != previous saved #{chain[:last_saved]}"
                 end
      end
      check_joiner_persist(ep, chain, fails, sides, host_loaded: loaded)
      if link_fault
        fails << "a link-fault episode wrote a save (#{saved[:digest]})" if saved
        return
      end
      return if ep[:timeout]
      if saved.nil?
        # Only a clean quit reaches here unfailed — and a clean quit on the
        # save-owning seat MUST write (decision 2); silence is a defect.
        fails << "no persist saved line after a clean quit" if clean_quit?(ep)
        return
      end
      expected = chain[:last_sessions] + 1
      if saved[:sessions] != expected
        fails << "sessions=#{saved[:sessions]} did not increment (previous #{chain[:last_sessions]})"
      end
      chain[:first_sessions] ||= saved[:sessions]
      chain[:last_sessions] = saved[:sessions]
      chain[:last_saved] = saved[:digest]
      chain[:links] << saved[:digest][0, 8]
    end

    def clean_quit?(ep)
      ep[:host_exit] == 0 &&
        ep[:host_log].match(NETPLAY)&.captures&.last == "quit"
    end

    def check_joiner_persist(ep, chain, fails, sides, host_loaded:)
      return unless sides.include?(:joiner) && ep[:joiner_log]
      j = ep[:joiner_log].scan(PERSIST)
           .map { |kind, digest, _s, source| { kind:, digest:, source: } }
           .find { |p| p[:kind] == "loaded" && p[:source] == "handshake" }
      if chain[:last_saved].nil? && host_loaded.nil?
        # Fresh episode: no save rode the wire — a joiner loaded line here
        # means the seats disagree about the world's existence.
        fails << "joiner shows a loaded line on a fresh episode (#{j[:digest]})" if j
      elsif host_loaded && j.nil?
        fails << "joiner has no handshake loaded line (host loaded #{host_loaded[:digest]})"
      elsif host_loaded && j[:digest] != host_loaded[:digest]
        fails << "handshake digest mismatch: joiner #{j[:digest]} != host #{host_loaded[:digest]}"
      end
    end

    def parse_seat(log, _side)
      out = {}
      if (m = log.match(BANNER))
        out[:seed] = m[1].to_i
        out[:quit_tick] = m[2].to_i
      end
      if (m = log.match(NETPLAY))
        out[:seat] = m[1].to_i
        out[:ticks] = m[2].to_i
        out[:desyncs] = m[3].to_i
        out[:reason] = m[4]
      end
      if (m = log.match(/^persist ERROR (.+)$/))
        out[:persist_error] = m[1]
      end
      out
    end
  end
end

# CLI shim: ruby soak/chain_check.rb tmp/soak/<run>  — reads run.json +
# ep*/{host,joiner}.log + ep*/exit, writes report.txt, exit 1 on FAIL.
if $PROGRAM_NAME == __FILE__
  run_dir = ARGV[0] or abort "usage: ruby soak/chain_check.rb tmp/soak/<run>"
  meta = JSON.parse(File.read(File.join(run_dir, "run.json")))
  episodes = Dir[File.join(run_dir, "ep*")].sort_by { |d| d[/\d+$/].to_i }.map do |dir|
    exits = {}
    exit_file = File.join(dir, "exit")
    File.read(exit_file).scan(/(\w+)=(-?\d+)/) { |k, v| exits[k] = v.to_i } if File.exist?(exit_file)
    read = ->(name) { p = File.join(dir, name); File.exist?(p) ? File.read(p) : nil }
    { index: dir[/\d+$/].to_i,
      host_log: read.call("host.log"), joiner_log: read.call("joiner.log"),
      host_exit: exits["host"], joiner_exit: exits["joiner"],
      timeout: exits.fetch("timeout", 0) == 1 }
  end
  abort "no episodes under #{run_dir}" if episodes.empty?
  pass, lines = Soak::ChainCheck.check(
    episodes,
    min_ticks: Integer(meta.fetch("ticks")),
    mode: meta.fetch("mode", "both"),
    allow_link_faults: meta["allow_link_faults"] ? true : false,
    seed_digest: meta["seed_digest"],
    zones: meta["zones"]
  )
  report = lines.join("\n") + "\n"
  File.write(File.join(run_dir, "report.txt"), report)
  print report
  exit(pass ? 0 : 1)
end
