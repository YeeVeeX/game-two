$LOAD_PATH.unshift(__dir__)
require "core/data_store"
require "app/cli"

# v17 CLI (spec Netplay spec): no flags = the window. --host / --join
# build the Net::Session FIRST; the joiner pre-pumps the handshake so a
# refusal (fingerprint/version mismatch) prints to the CONSOLE and exits
# nonzero — the bindings-error precedent: no window ever opens on a
# refused join. The host opens the window immediately (HOSTING screen);
# hosting waits indefinitely, Esc cancels.
#
# v18 solo persistence (spec decisions 2/5/6a/16): load + strict-decode
# the save BEFORE the window (a refused save aborts to the console, exit
# 1); per-session seed (the fixed-seed-0 solo field is dead); the save
# coordinator writes at clean quit only. --fresh backs the save up and
# starts over. Netplay persistence (host custody + SESSION transfer) is
# the protocol-v2 increment — sessions get NO save wiring until then.
data = Core::DataStore.new(File.expand_path("../data", __dir__))

begin
  opts = App::Cli.parse(ARGV, default_port: data["netplay"][:port])
rescue ArgumentError => e
  abort e.message
end

if opts.nil? || opts[:mode] == :solo
  require "app/window"
  require "app/save_store"
  store = App::SaveStore.new(
    path: File.expand_path("../#{data['persistence'][:save_path]}", __dir__)
  )
  if opts && opts[:fresh] && data["persistence"][:backup_on_fresh]
    bak = store.backup_fresh!
    puts "fresh start: existing save backed up to #{bak}" if bak
  end
  result = store.load(data:)
  result.notices.each { |n| warn n }
  save_facts = nil
  case result
  when App::SaveStore::Refused
    abort result.refusal # pre-window, exit 1 (the bindings-error precedent)
  when App::SaveStore::Loaded
    save_facts = result.facts
    puts App::SaveStore.persist_line("loaded", facts: save_facts,
                                     digest: result.digest, source: "file")
  else
    puts App::SaveStore.persist_line("fresh", source: "fresh")
  end
  seed = App::Cli.new_seed
  puts "TELEMETRY session seed=#{seed}"
  saver = App::SaveCoordinator.new(store:, owner: true)
  App::Window.new(seed:, save: save_facts, saver:).show
  exit
end

require "net/session"
config = data["netplay"]
now_ms = -> { Process.clock_gettime(Process::CLOCK_MONOTONIC) * 1000.0 }

session, relaunch =
  case opts[:mode]
  when :host
    puts "hosting on port #{opts[:port]} (Esc cancels)"
    [Net::Session.host(port: opts[:port], config:, seed: App::Cli.new_seed),
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
warn session.refusal if session.refusal
exit App::Cli.exit_status(reason: session.reason, refusal: session.refusal)
