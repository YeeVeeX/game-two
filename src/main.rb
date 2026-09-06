# M5a audio (contract §3): SDL's audio-driver hint is read at SDL audio-
# subsystem init — set at PROCESS ENTRY, before any gosu require, so Gosu's
# audio lands on the dummy backend and miniaudio owns the real device.
# Every launcher funnels through this file, so this IS process entry.
ENV["SDL_AUDIODRIVER"] = "dummy"

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

# v18 soak (brief D1/D2/D3): the seeded autopilot + the save override.
# The banner is the ONE new output line and prints ONLY under --bot
# (parse yields no :bot key otherwise — pinned); Cli.parse already
# refused any bot in a save-owning seat without --save.
autopilot = nil
if (bot = opts&.dig(:bot))
  require "app/autopilot"
  # Soak logs are read while the process runs (heartbeats) and must
  # survive a timeout kill — unbuffer, bot lanes only (a buffered seat
  # killed by the orchestrator's fuse would leave an EMPTY log and the
  # episode bundle would lose all forensics). Human paths untouched.
  $stdout.sync = true
  autopilot = App::Autopilot.new(seed: bot[:seed] || App::Cli.new_seed,
                                 quit_tick: bot[:ticks] || App::Autopilot::DEFAULT_QUIT_TICK)
  puts autopilot.banner
end
# v22 T1 (L20-1): this machine's PLAYER identity keys its characters in
# every save. Humans read (and on first boot write) data/player.local.json;
# a bot seat derives bot-<seed> and never touches the file (replays and
# soaks stay byte-identical). The id rides HELLO; no surface shows it.
require "app/player_file"
player_id = autopilot ? App::PlayerFile.bot_id(autopilot.seed) : App::PlayerFile.load.player_id
# Quality-flywheel lane 1 (2026-08-19): start zone rides a bot or a scratch
# save (Cli refused it bare). The line is soak-oracle surface: chain_check
# asserts it per zoned episode on BOTH seats.
start_zone = opts&.dig(:start_zone)
save_path = opts&.dig(:save)
save_path = File.expand_path(save_path) if save_path
# Dev-warp law (owner order 2026-09-05): a human start zone NEVER lands on
# the live save — an explicit --save that resolves to the persistence path
# is refused by name, pre-window (the bindings-error precedent).
live_save = File.expand_path("../#{data['persistence'][:save_path]}", __dir__)
if start_zone && autopilot.nil? && save_path == live_save
  abort "--start-zone refuses the live save #{save_path} (point --save at a scratch file; bin/warp does)"
end
puts "START_ZONE zone=#{start_zone}" if start_zone

# M5a: audio boots per contract §3 (engine + sink before the window; ONE
# engine per process). Optional by law — absent library / bot seat = one
# named line + silent game; failures never kill the game (Junior's
# machine has no library and must play unchanged).
require "app/audio_bridge"
audio = App::AudioBridge.boot(bot: !autopilot.nil?, smoke: !opts&.dig(:audio_smoke).nil?)

if opts.nil? || opts[:mode] == :solo
  require "app/window"
  require "app/save_store"
  store = App::SaveStore.new(
    path: save_path || File.expand_path("../#{data['persistence'][:save_path]}", __dir__)
  )
  if opts && opts[:fresh] && data["persistence"][:backup_on_fresh]
    bak = store.backup_fresh!
    puts "fresh start: existing save backed up to #{bak}" if bak
  end
  result = store.load(data:, player_id:)
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
  App::Window.new(seed:, save: save_facts, saver:, bot: autopilot, audio:,
                  start_zone:, players: { 1 => player_id }).show
  exit
end

require "net/session"
require "app/save_store"
require "game/save_state"
config = data["netplay"]
now_ms = -> { Process.clock_gettime(Process::CLOCK_MONOTONIC) * 1000.0 }
store = App::SaveStore.new(
  path: save_path || File.expand_path("../#{data['persistence'][:save_path]}", __dir__)
)

session, relaunch, saver =
  case opts[:mode]
  when :host
    if opts[:fresh] && data["persistence"][:backup_on_fresh]
      bak = store.backup_fresh!
      puts "fresh start: existing save backed up to #{bak}" if bak
    end
    result = store.load(data:, player_id:)
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
    [Net::Session.host(port: opts[:port], config:, seed: App::Cli.new_seed, player_id:,
                       save_facts:, save_canonical:, save_digest:, save_schema:),
     "bin/play --host #{opts[:port]}",
     App::SaveCoordinator.new(store:, owner: true)]
  when :join
    begin
      s = Net::Session.join(host: opts[:host], port: opts[:port], config:, player_id:,
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
App::Window.new(session:, relaunch:, saver:, bot: autopilot, audio:,
                start_zone:).show
warn session.refusal if session.refusal
exit App::Cli.exit_status(reason: session.reason, refusal: session.refusal)
