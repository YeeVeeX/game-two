$LOAD_PATH.unshift(__dir__)
require "core/data_store"
require "app/cli"

# v17 CLI (spec Netplay spec): no flags = the window, unchanged. --host /
# --join build the Net::Session FIRST; the joiner pre-pumps the handshake
# so a refusal (fingerprint/version mismatch) prints to the CONSOLE and
# exits nonzero — the bindings-error precedent: no window ever opens on a
# refused join. The host opens the window immediately (HOSTING screen);
# hosting waits indefinitely, Esc cancels.
begin
  opts = App::Cli.parse(ARGV, default_port: Core::DataStore.new(
    File.expand_path("../data", __dir__)
  )["netplay"][:port])
rescue ArgumentError => e
  abort e.message
end

if opts.nil?
  require "app/window"
  App::Window.new.show
  exit
end

require "net/session"
config = Core::DataStore.new(File.expand_path("../data", __dir__))["netplay"]
now_ms = -> { Process.clock_gettime(Process::CLOCK_MONOTONIC) * 1000.0 }

session, relaunch =
  case opts[:mode]
  when :host
    puts "hosting on port #{opts[:port]} (Esc cancels)"
    [Net::Session.host(port: opts[:port], config:, seed: Random.new_seed & 0xffff_ffff),
     "bin/play --host #{opts[:port]}"]
  when :join
    begin
      s = Net::Session.join(host: opts[:host], port: opts[:port], config:)
    rescue SystemCallError => e
      abort "could not connect to #{opts[:host]}:#{opts[:port]} — #{e.message}"
    end
    # Pre-window pump: HELLO verification resolves here (bounded by
    # abort_stall_ms via the session's own handshake timeout).
    loop do
      s.update(now_ms.call)
      break if s.params_known? || s.ended?
      sleep(0.005)
    end
    [s, "bin/play --join #{opts[:host]}:#{opts[:port]}"]
  end

if session.ended?
  abort(session.refusal || "session ended during handshake (#{session.reason})")
end

require "app/window"
App::Window.new(session:, relaunch:).show
if session.refusal
  warn session.refusal
  exit 1
end
