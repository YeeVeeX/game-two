require_relative "../test_helper"
require "core/data_store"
require "core/input"
require "game/world"
require "game/save_state"
require "net/session"
require "app/save_store"
require "app/cli"
require "tmpdir"
require "fileutils"
require "digest"

# v18 increment 3, spec test lane 3 — THE two-session netplay persistence
# lane: two REAL session PAIRS over real loopback TCP in one process,
# per-seat tmp save roots (Codex fold #19), a REAL SaveStore file written
# by the host coordinator at quit, then a second pair that RESUMES from
# that file — the SEVENTEENTH's Half A chain, mechanized: fresh -> saved
# digest -> loaded digest (file on the host, wire bytes on the joiner) ->
# carried fact -> zero desyncs -> joiner root EMPTY.
#
# No mocks: real Worlds, real sockets, real files. The fake clock is
# caller-fed (no test waits on real time); mutations that stage the
# carried facts land IDENTICALLY on both sims at an asserted-equal tick
# (the divergence test proves one-sided pokes desync — symmetry is the
# staging law here).
class NetplayPersistenceTest < Minitest::Test
  DATA = Core::DataStore.new(File.expand_path("../../data", __dir__))
  CFG = DATA["netplay"]
  ECO = DATA["balance/economy"]
  HELLO = { version: 2, ruby: "3.4.10", platform: "test", fingerprint: "c" * 32,
            digest_version: 1 }.freeze
  VALIDATOR = ->(facts) { Game::SaveState.refusal_for(facts, data: DATA) }

  def setup
    @host_root = Dir.mktmpdir("host_save")
    @join_root = Dir.mktmpdir("join_save")
    @store = App::SaveStore.new(path: File.join(@host_root, "world.json"))
    @sessions = []
  end

  def teardown
    @sessions.each do |s|
      next if s.nil? || s.ended?
      s.quit!(10**12)
      s.update(10**12 + CFG[:drain_timeout_ms] + 1)
    end
    FileUtils.remove_entry(@host_root)
    FileUtils.remove_entry(@join_root)
  end

  # The joiner is wired exactly as main.rb wires it: schema + strict
  # decoder, NO store, NO coordinator — its save root must stay empty.
  def session_pair(seed:, epoch:, save_facts: nil, save_canonical: nil, save_digest: nil,
                   join_id: "bot-2")
    schema = save_canonical ? Game::SaveState::SCHEMA : nil
    h = Net::Session.host(player_id: "bot-1", bind: "127.0.0.1", port: 0, config: CFG, seed:, epoch:,
                          hello: HELLO.dup, save_facts:, save_canonical:,
                          save_digest:, save_schema: schema)
    j = Net::Session.join(player_id: join_id, host: "127.0.0.1", port: h.port, config: CFG,
                          hello: HELLO.dup, save_schema: Game::SaveState::SCHEMA,
                          save_validator: VALIDATOR)
    @sessions << h << j
    [h, j]
  end

  def handshake_and_attach(h, j)
    t = 0
    400.times do
      break if h.params_known? && j.params_known?
      h.update(t)
      j.update(t)
      t += 10
    end
    flunk "handshake never produced params" unless h.params_known? && j.params_known?
    # v22 T1: both seats seat the HELLO-learned map (identical by construction).
    wh = Game::World.new(DATA, seed: h.params.seed, seats: 2, save: h.params.save, players: h.players)
    wj = Game::World.new(DATA, seed: j.params.seed, seats: 2, save: j.params.save, players: j.players)
    h.attach(wh)
    j.attach(wj)
    50.times do
      break if h.running? && j.running?
      h.update(t)
      j.update(t)
      t += 10
    end
    flunk "START barrier never resolved" unless h.running? && j.running?
    [wh, wj, t]
  end

  def scripted(seed_offset)
    Core::ScriptedInput.new(frames: (0..4200).to_h do |f|
      actions = case (f + seed_offset) % 130
                when 0...45 then ["right"]
                when 45...65 then ["attack"]
                when 65...95 then ["up"]
                else []
                end
      [f, actions]
    end)
  end

  def run_ticks(h, j, in1, in2, t, until_tick:)
    600.times do
      break if h.ticks >= until_tick && j.ticks >= until_tick
      break if h.ended? || j.ended?
      h.update(t, in1)
      j.update(t, in2)
      t += 10
    end
    t
  end

  def quit_both(h, j, t, initiator:)
    initiator.quit!(t)
    60.times do
      break if h.ended? && j.ended?
      h.update(t)
      j.update(t)
      t += 10
    end
    flunk "quit drain never resolved" unless h.ended? && j.ended?
    t
  end

  def digest_of(persist_line)
    persist_line[/digest=(\h{32})/, 1] || flunk("no digest in: #{persist_line}")
  end

  # --- THE CHAIN (Half A mechanized) -----------------------------------------

  def test_fresh_save_resume_chain_with_carried_facts_and_an_empty_joiner_root
    # --- session pair 1: fresh world ------------------------------------
    h1, j1 = session_pair(seed: 11, epoch: 1010)
    wh1, wj1, t = handshake_and_attach(h1, j1)
    assert_nil h1.params.save, "pair 1 is a fresh world"
    in1 = scripted(0)
    in2 = scripted(60)
    t = run_ticks(h1, j1, in1, in2, t, until_tick: 30)

    # Stage the carried facts on BOTH sims at the SAME executed tick —
    # identical mutations keep lockstep honest (asserted by digests below).
    assert_equal h1.ticks, j1.ticks, "staging law: mutate only at equal ticks"
    [wh1, wj1].each do |w|
      w.pack.bank!(75)
      w.restore_breach!("district", [42, 13])
    end
    t = run_ticks(h1, j1, in1, in2, t, until_tick: 300)
    assert_operator h1.ticks, :>=, 300
    assert_equal 0, h1.lockstep.desyncs, "identical staging never desyncs"
    assert_equal h1.digest_log, j1.digest_log

    banked_at_close = wh1.pack.banked
    assert_operator banked_at_close, :>=, 75, "the carried fact is strictly positive"
    t = quit_both(h1, j1, t, initiator: h1)
    assert_equal :quit, h1.reason

    # Host coordinator writes the REAL file (owner ∧ reason=:quit).
    saver1 = App::SaveCoordinator.new(store: @store, owner: true)
    line1 = saver1.close(world: wh1, reason: h1.reason)
    saved_digest = digest_of(line1)
    assert_match(/\ATELEMETRY persist saved /, line1)
    assert_match(/sessions=1/, line1, "sessions increments AT the write")
    assert File.exist?(File.join(@host_root, "world.json"))

    # --- session pair 2: resume from the file ---------------------------
    result = @store.load(data: DATA, player_id: "bot-1") # the host seat's id (harness default)
    assert_instance_of App::SaveStore::Loaded, result
    assert_equal saved_digest, result.digest,
                 "host loaded digest == saved digest (the file half of the chain)"
    canonical = Game::SaveState.canonical_bytes(result.facts)
    assert_nil Net::Session.session_wire_refusal(
      save_canonical: canonical, save_digest: result.digest,
      save_schema: Game::SaveState::SCHEMA, config: CFG,
      budget: DATA["persistence"][:wire_budget_bytes]
    ), "a real save passes the host-start wire preflight"

    h2, j2 = session_pair(seed: 22, epoch: 2020, save_facts: result.facts,
                          save_canonical: canonical, save_digest: result.digest)
    wh2, wj2, t2 = handshake_and_attach(h2, j2)

    # The wire half of the chain: the joiner's digest is RECOMPUTED from
    # received bytes and must equal the host's saved digest verbatim.
    assert_equal saved_digest, j2.params.save_digest
    assert_equal saved_digest, h2.params.save_digest
    assert_equal 1, result.facts["counters"]["sessions"]

    # Carried facts: banked survived the boundary; the breach is open on
    # BOTH constructed worlds; the field re-seeded (new seed by design).
    assert_equal banked_at_close, wh2.pack.banked, "banked2_start == banked1_end"
    assert_equal banked_at_close, wj2.pack.banked
    assert wh2.breached?("district", [42, 13])
    assert wj2.breached?("district", [42, 13])
    assert_equal Net::StateDigest.canonical(wh2.digest_snapshot),
                 Net::StateDigest.canonical(wj2.digest_snapshot),
                 "both seats constructed identical worlds from the transferred save"

    # The resumed pair holds: K ticks, zero desyncs, identical streams.
    in3 = scripted(15)
    in4 = scripted(90)
    t2 = run_ticks(h2, j2, in3, in4, t2, until_tick: 600)
    assert_operator h2.ticks, :>=, 600
    assert_equal 0, h2.lockstep.desyncs
    assert_equal 0, j2.lockstep.desyncs
    assert_equal h2.digest_log, j2.digest_log

    # JOINER-initiated clean quit still saves on the host (decision 2,
    # panel DS-Q4: BYE{quit} lands reason=:quit on BOTH seats).
    quit_both(h2, j2, t2, initiator: j2)
    assert_equal :quit, h2.reason, "joiner quit concludes :quit on the host"
    saver2 = App::SaveCoordinator.new(store: @store, owner: true)
    line2 = saver2.close(world: wh2, reason: h2.reason)
    refute_nil line2, "the host writes on a joiner-initiated clean quit"
    assert_match(/sessions=2/, line2, "the chain accretes")

    # The joiner NEVER persists the shared world (F2): its root is EMPTY
    # after two full sessions, and the host root carries exactly the save.
    assert_empty Dir.children(@join_root), "joiner save root must stay empty"
    assert_equal ["world.json"], Dir.children(@host_root).sort
  end

  # --- v22 T1: guest records across the wire (council s133 Q5/Q6) --------------
  # A guest with NO record in the host's save is created at session start
  # on BOTH seats from HELLO's id + the transferred save: digests agree from
  # tick 0 and through K ticks; at the host's clean quit the guest's record
  # is written with level/xp MIRRORING the party level (the T1 interim rule)
  # while the absent player's record rides along verbatim.
  def test_new_guest_record_is_created_on_both_seats_mirrored_and_persisted
    # pair 1: bot-1 hosts, bot-2 joins a fresh world -> both records saved
    h1, j1 = session_pair(seed: 51, epoch: 5050)
    wh1, _wj1, t = handshake_and_attach(h1, j1)
    t = run_ticks(h1, j1, scripted(0), scripted(60), t, until_tick: 30)
    quit_both(h1, j1, t, initiator: h1)
    App::SaveCoordinator.new(store: @store, owner: true).close(world: wh1, reason: h1.reason)
    first = @store.load(data: DATA, player_id: "bot-1")
    assert_equal %w[bot-1 bot-2], first.facts["characters"].keys.sort
    bot2_as_saved = first.facts["characters"]["bot-2"]

    # pair 2: bot-3 joins the SAME save -> created on both seats, bot-2 unseated
    canonical = Game::SaveState.canonical_bytes(first.facts)
    h2, j2 = session_pair(seed: 52, epoch: 5252, save_facts: first.facts,
                          save_canonical: canonical, save_digest: first.digest, join_id: "bot-3")
    wh2, wj2, t2 = handshake_and_attach(h2, j2)
    assert_equal({ 1 => "bot-1", 2 => "bot-3" }, h2.players)
    assert_equal h2.players, j2.players
    [wh2, wj2].each do |w|
      assert_equal %w[bot-1 bot-2 bot-3], w.party.ids, "the newcomer exists on this seat"
      assert_equal 1, w.party.records["bot-3"].level, "no migration block -> new_character.level"
    end
    assert_equal Net::StateDigest.canonical(wh2.digest_snapshot),
                 Net::StateDigest.canonical(wj2.digest_snapshot),
                 "both seats built the same Party from HELLO + the transferred save (tick 0)"
    t2 = run_ticks(h2, j2, scripted(5), scripted(70), t2, until_tick: 30)
    # The shared progression grows IDENTICALLY on both sims (staging law:
    # equal ticks, same poke) — the seated guest must mirror it on both.
    assert_equal h2.ticks, j2.ticks
    [wh2, wj2].each { |w| w.progression.load_progress!(level: 3, xp: 4) }
    t2 = run_ticks(h2, j2, scripted(5), scripted(70), t2, until_tick: 240)
    assert_equal 0, h2.lockstep.desyncs, "guest records never desync the pair"
    assert_equal h2.digest_log, j2.digest_log
    quit_both(h2, j2, t2, initiator: j2)
    App::SaveCoordinator.new(store: @store, owner: true).close(world: wh2, reason: h2.reason)

    second = @store.load(data: DATA, player_id: "bot-1")
    chars = second.facts["characters"]
    assert_equal %w[bot-1 bot-2 bot-3], chars.keys.sort
    assert_equal [3, 4], chars["bot-1"].values_at("level", "xp")
    assert_equal [3, 4], chars["bot-3"].values_at("level", "xp"), "the seated guest persisted the MIRROR"
    assert_equal bot2_as_saved, chars["bot-2"], "the absent player's record rides along verbatim"
    assert_equal 2, second.facts["counters"]["sessions"]
    assert_empty Dir.children(@join_root), "the joiner still never persists"
  end

  # --- negative custody lanes ---------------------------------------------------

  def test_non_clean_endings_write_nothing_even_on_the_host
    h, j = session_pair(seed: 33, epoch: 3030)
    wh, _wj, t = handshake_and_attach(h, j)
    t = run_ticks(h, j, scripted(0), scripted(60), t, until_tick: 30)
    wh.pack.bank!(9) # one-sided poke: a REAL divergence
    200.times do
      break if h.ended? && j.ended?
      h.update(t, nil)
      j.update(t, nil)
      t += 10
    end
    assert_equal :desync, h.reason
    saver = App::SaveCoordinator.new(store: @store, owner: true)
    assert_nil saver.close(world: wh, reason: h.reason),
               "a diverged world must never poison the save"
    refute File.exist?(File.join(@host_root, "world.json"))
  end

  def test_a_v1_peer_refuses_at_hello_naming_the_protocol_version
    h = Net::Session.host(player_id: "bot-1", bind: "127.0.0.1", port: 0, config: CFG, seed: 44, epoch: 4040,
                          hello: HELLO.dup)
    j = Net::Session.join(player_id: "bot-2", host: "127.0.0.1", port: h.port, config: CFG,
                          hello: HELLO.merge(version: 1),
                          save_schema: Game::SaveState::SCHEMA, save_validator: VALIDATOR)
    @sessions << h << j
    t = 0
    200.times do
      break if h.ended? && j.ended?
      h.update(t)
      j.update(t)
      t += 10
    end
    assert h.ended? && j.ended?
    [h, j].each do |s|
      assert_match(/protocol version/, s.refusal, "the v1/v2 skew is NAMED")
      assert_equal 1, App::Cli.exit_status(reason: s.reason, refusal: s.refusal)
    end
  end
end
