module App
  # v17 CLI (spec Netplay spec): the launchers consume the optional locale
  # (env GAME_LOCALE) and forward everything else here. No flags = window
  # mode UNCHANGED (returns nil). Errors raise ArgumentError with the exact
  # usage — main.rb aborts to the console, nonzero (the bindings-error
  # precedent: the message reaches the person who typed the command).
  module Cli
    USAGE = "usage: bin/play [locale] [--fresh | --host [port] | --join <ip[:port]>] " \
            "[--save <path>] [--bot [seed] [--bot-ticks <n>]]".freeze

    # Exit-status seam (v17 SIXTEENTH support): the coop launchers relaunch
    # ONLY on link faults — a clean Esc or an honest desync/protocol end
    # stops the loop (etapa-1 law: end LOUDLY, never mask).
    #   0 = clean end (quit/desync/protocol — console already carries the
    #       report), 1 = refusal (needs a human: pull/version), 2 = link
    #       fault (conn_lost — safe to rehost/rejoin).
    EXIT_LINK_FAULT = 2

    module_function

    # argv -> nil | {mode: :solo, fresh: true} | {mode: :host, port:[, fresh: true]} |
    #         {mode: :join, host:, port:}
    def parse(argv, default_port:)
      args = argv.dup
      return nil if args.empty?
      # v18: --fresh is an ORDER-FREE modifier — start a fresh world; the
      # existing save backs up FIRST (decision 14's irreversibility
      # guard). Solo resets the solo-owned save; with --host it resets
      # the SHARED world at the custody seat (increment-3 spark order).
      # Never with --join: the joiner owns no save to reset.
      fresh = !args.reject! { |a| a == "--fresh" }.nil?
      # v18 session-8 soak (brief D3): --save/--bot/--bot-ticks are
      # order-free modifiers like --fresh. --save points the save at a
      # scratch path; --bot is the seeded autopilot. The quarantine law:
      # a bot in a save-owning seat (solo/--host) REFUSES without --save
      # — a bot must be UNABLE to touch the real world save; the joiner
      # never keeps a save, so --join --save refuses and joiner bots need
      # no --save (F2).
      save = extract_value!(args, "--save")
      bot = extract_bot!(args)
      mods = {}
      mods[:fresh] = true if fresh
      mods[:save] = save if save
      mods[:bot] = bot if bot
      if args.empty?
        require_bot_save!(mods)
        return { mode: :solo }.merge(mods)
      end
      case (flag = args.shift)
      when "--host"
        port = args.shift
        raise ArgumentError, "--host takes at most a port\n#{USAGE}" unless args.empty?
        require_bot_save!(mods)
        { mode: :host, port: port ? parse_port(port) : default_port }.merge(mods)
      when "--join"
        raise ArgumentError, "--fresh cannot join (no save custody)\n#{USAGE}" if fresh
        raise ArgumentError, "--save cannot join (the joiner never keeps the save)\n#{USAGE}" if save
        addr = args.shift
        raise ArgumentError, "--join needs the host address\n#{USAGE}" if addr.nil? || addr.start_with?("-")
        raise ArgumentError, "--join takes one address\n#{USAGE}" unless args.empty?
        host, port = addr.split(":", 2)
        raise ArgumentError, "--join needs the host address\n#{USAGE}" if host.empty?
        { mode: :join, host:, port: port ? parse_port(port) : default_port }.merge(mods)
      else
        raise ArgumentError, "unknown argument #{flag.inspect}\n#{USAGE}"
      end
    end

    # Order-free `<flag> <value>` extraction; the value must exist and
    # not be another flag.
    def extract_value!(args, flag)
      i = args.index(flag)
      return nil if i.nil?
      args.delete_at(i)
      val = args[i]
      raise ArgumentError, "#{flag} needs a value\n#{USAGE}" if val.nil? || val.start_with?("-")
      args.delete_at(i)
      val
    end

    # --bot [seed]: the seed is optional — a bare integer right after the
    # flag binds to it (soak tooling surface; humans don't type --bot).
    # --bot-ticks <n> = the bot's quit tick (test-driver cap, not balance).
    def extract_bot!(args)
      ticks_raw = extract_value!(args, "--bot-ticks")
      i = args.index("--bot")
      if i.nil?
        raise ArgumentError, "--bot-ticks needs --bot\n#{USAGE}" if ticks_raw
        return nil
      end
      args.delete_at(i)
      seed = args[i]&.match?(/\A\d+\z/) ? Integer(args.delete_at(i)) : nil
      ticks = nil
      if ticks_raw
        ticks = Integer(ticks_raw, exception: false)
        raise ArgumentError, "bad --bot-ticks #{ticks_raw.inspect} (positive ticks)\n#{USAGE}" unless ticks&.positive?
      end
      { seed:, ticks: }
    end

    # D3 quarantine refusal — named, functional-plain, pre-window exit 1
    # through the existing abort path.
    def require_bot_save!(mods)
      return unless mods[:bot] && !mods[:save]
      raise ArgumentError,
            "--bot needs --save <path> in solo or --host mode " \
            "(a bot never touches the real save)\n#{USAGE}"
    end

    def parse_port(raw)
      port = Integer(raw, exception: false)
      raise ArgumentError, "bad port #{raw.inspect} (1-65535)\n#{USAGE}" unless port&.between?(1, 65_535)
      port
    end

    # One seed derivation for every session-owning launch path (v18
    # decision 16: the solo path was FIXED at seed 0 — every solo session
    # replayed the same field; now solo and host both draw here and the
    # seed prints for reproducibility).
    def new_seed = Random.new_seed & 0xffff_ffff

    # (reason, refusal) -> process exit status; see EXIT_LINK_FAULT above.
    def exit_status(reason:, refusal:)
      return 1 if refusal
      return EXIT_LINK_FAULT if reason == :conn_lost
      0
    end
  end
end
