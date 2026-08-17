module App
  # v17 CLI (spec Netplay spec): the launchers consume the optional locale
  # (env GAME_LOCALE) and forward everything else here. No flags = window
  # mode UNCHANGED (returns nil). Errors raise ArgumentError with the exact
  # usage — main.rb aborts to the console, nonzero (the bindings-error
  # precedent: the message reaches the person who typed the command).
  module Cli
    USAGE = "usage: bin/play [locale] [--host [port] | --join <ip[:port]>]".freeze

    # Exit-status seam (v17 SIXTEENTH support): the coop launchers relaunch
    # ONLY on link faults — a clean Esc or an honest desync/protocol end
    # stops the loop (etapa-1 law: end LOUDLY, never mask).
    #   0 = clean end (quit/desync/protocol — console already carries the
    #       report), 1 = refusal (needs a human: pull/version), 2 = link
    #       fault (conn_lost — safe to rehost/rejoin).
    EXIT_LINK_FAULT = 2

    module_function

    # argv -> nil | {mode: :host, port:} | {mode: :join, host:, port:}
    def parse(argv, default_port:)
      args = argv.dup
      return nil if args.empty?
      case (flag = args.shift)
      when "--host"
        port = args.shift
        raise ArgumentError, "--host takes at most a port\n#{USAGE}" unless args.empty?
        { mode: :host, port: port ? parse_port(port) : default_port }
      when "--join"
        addr = args.shift
        raise ArgumentError, "--join needs the host address\n#{USAGE}" if addr.nil? || addr.start_with?("-")
        raise ArgumentError, "--join takes one address\n#{USAGE}" unless args.empty?
        host, port = addr.split(":", 2)
        raise ArgumentError, "--join needs the host address\n#{USAGE}" if host.empty?
        { mode: :join, host:, port: port ? parse_port(port) : default_port }
      else
        raise ArgumentError, "unknown argument #{flag.inspect}\n#{USAGE}"
      end
    end

    def parse_port(raw)
      port = Integer(raw, exception: false)
      raise ArgumentError, "bad port #{raw.inspect} (1-65535)\n#{USAGE}" unless port&.between?(1, 65_535)
      port
    end

    # (reason, refusal) -> process exit status; see EXIT_LINK_FAULT above.
    def exit_status(reason:, refusal:)
      return 1 if refusal
      return EXIT_LINK_FAULT if reason == :conn_lost
      0
    end
  end
end
