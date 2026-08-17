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
# starts over (solo lane).
#
# v18 increment 3 — netplay persistence (decisions 2/5/6): the HOST
# loads + strict-decodes BEFORE listening and preflights the ACTUAL
# encoded SESSION line against wire_budget_bytes (a too-big save refuses
# at the console, never mid-handshake); SESSION transfers the canonical
# facts string; the JOINER strict-decodes during the pre-window pump (a
# refused save prints to the console and exits 1 — no window) and NEVER
# persists the shared world; the host coordinator writes IFF the end is
# clean (either seat's Esc lands reason=:quit on BOTH seats).
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
require "app/save_store"
require "game/save_state"
config = data["netplay"]
now_ms = -> { Process.clock_gettime(Process::CLOCK_MONOTONIC) * 1000.0 }
store = App::SaveStore.new(
  path: File.expand_path("../#{data['persistence'][:save_path]}", __dir__)
)

session, relaunch, saver =
  case opts[:mode]
  when :host
    if opts[:fresh] && data["persistence"][:backup_on_fresh]
      bak = store.backup_fresh!
      puts "fresh start: existing save backed up to #{bak}" if bak
    end
    result = store.load(data:)
    result.notices.each { |n| warn n }
    save_facts = nil
    save_canonical = nil
    save_digest = nil
    case result
    when App::SaveStore::Refused
      abort result.refusal # pre-listen, exit 1 (the bindings-error precedent)
    when App::SaveStore::Loaded
      save_facts = result.facts
      save_canonical = Game::SaveState.canonical_bytes(save_facts)
      save_digest = result.digest
      puts App::SaveStore.persist_line("loaded", facts: save_facts,
                                       digest: save_digest, source: "file")
    else
      puts App::SaveStore.persist_line("fresh", source: "fresh")
    end
    save_schema = save_facts && Game::SaveState::SCHEMA
    if (refusal = Net::Session.session_wire_refusal(
      save_canonical:, save_digest:, save_schema:, config:,
      budget: data["persistence"][:wire_budget_bytes]
    ))
      abort refusal # decision 6c: refuse NAMED before the socket opens
    end
    puts "hosting on port #{opts[:port]} (Esc cancels)"
    [Net::Session.host(port: opts[:port], config:, seed: App::Cli.new_seed,
                       save_facts:, save_canonical:, save_digest:, save_schema:),
     "bin/play --host #{opts[:port]}",
     App::SaveCoordinator.new(store:, owner: true)]
  when :join
    begin
      s = Net::Session.join(host: opts[:host], port: opts[:port], config:,
                            save_schema: Game::SaveState::SCHEMA,
                            save_validator: ->(f) { Game::SaveState.refusal_for(f, data:) })
    rescue SystemCallError => e
      abort "could not connect to #{opts[:host]}:#{opts[:port]} — #{e.message}"
    end
    # Pre-window pump: HELLO verification AND the save's strict decode
    # resolve here (bounded by abort_stall_ms via the session's own
    # handshake timeout) — a refused save never opens a window.
    loop do
      s.update(now_ms.call)
      break if s.params_known? || s.ended?
      sleep(0.005)
    end
    # The joiner NEVER persists the shared world (F2): no coordinator.
    [s, "bin/play --join #{opts[:host]}:#{opts[:port]}", nil]
  end

if session.ended?
  abort(session.refusal || "session ended during handshake (#{session.reason})")
end

# Joiner-side loaded line: digest RECOMPUTED from the received bytes
# (decision 5); the host printed its own loaded/fresh line above.
if !session.host? && session.params_known? && session.params.save
  puts App::SaveStore.persist_line("loaded", facts: session.params.save,
                                   digest: session.params.save_digest,
                                   source: "handshake")
end

require "app/window"
App::Window.new(session:, relaunch:, saver:).show
warn session.refusal if session.refusal
exit App::Cli.exit_status(reason: session.reason, refusal: session.refusal)
