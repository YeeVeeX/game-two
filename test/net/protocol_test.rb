require_relative "../test_helper"
require "net/protocol"
require "core/input"

# v17 increment 3: the wire vocabulary. Codec round-trips, shape faults,
# framing (split/coalesced/partial/oversize), the pinned action bit order,
# and SampledInput's frozen-mask semantics (sampling law, decision 1).
class ProtocolTest < Minitest::Test
  Held = Struct.new(:actions) do
    def down?(action) = actions.include?(action)
  end

  # --- codec ---------------------------------------------------------------

  def test_protocol_version_is_four
    # v18 decision 8 pinned ONE bump for that cycle (v2, 11-bit mask).
    # v3 (2026-08-20, post-v18-close owner order): 12-bit mask — :aim
    # appends at bit 11. v4 (v22 T1): HELLO gains the REQUIRED player_id
    # field. Append-only law holds; the handshake refuses mixed builds by
    # version field, NAMED.
    assert_equal 4, Net::Protocol::VERSION
    assert_equal %i[version ruby platform fingerprint digest_version player_id],
                 Net::Protocol::MESSAGES[:hello], "HELLO = five build fields + identity"
  end

  def test_every_message_type_round_trips
    examples = {
      hello: { version: 2, ruby: "3.4.10", platform: "x64-mingw-ucrt",
               fingerprint: "abc123", digest_version: 1,
               player_id: "0f7e2c1a-4b3d-4c2e-9a1b-1234567890ab" },
      probe: { n: 3 }, probe_ack: { n: 3 },
      session: { session_id: "s-42", seed: 42, d: 8, digest_every: 60,
                 save_schema: 1, save_digest: "a" * 32,
                 save: '{"banked":7}' },
      ready: {}, start: {},
      input: { t: 120, bits: 517 },
      digest: { t: 60, md5: "a4150c43669b9783e59cb6c39c322b67" },
      desync: { t: 180 },
      bye: { reason: "quit" }
    }
    assert_equal Net::Protocol::MESSAGES.keys.sort, examples.keys.sort,
                 "example coverage drifted from the message vocabulary"
    examples.each do |type, fields|
      line = Net::Protocol.encode(type, **fields)
      assert line.end_with?("\n"), "#{type}: one newline-terminated line"
      decoded = Net::Protocol.decode(line.chomp)
      assert_equal type, decoded[:m]
      fields.each { |k, v| assert_equal v, decoded[k], "#{type}.#{k}" }
    end
  end

  def test_input_line_stays_tiny
    line = Net::Protocol.encode(:input, t: 999_999, bits: 2047) # all 11 v2 bits held
    assert_operator line.bytesize, :<=, 40, "per-tick cost is the whole transport bet"
  end

  def test_session_carries_the_save_vocabulary_and_null_save_for_fresh
    # v2 FINAL vocabulary pin (decision 8): a second silent bump cannot
    # happen — save_schema/save_digest/save are REQUIRED keys (null for a
    # fresh world; JSON null keeps the key present).
    assert_equal %i[session_id seed d digest_every save_schema save_digest save],
                 Net::Protocol::MESSAGES[:session]
    line = Net::Protocol.encode(:session, session_id: "abc", seed: 1, d: 8,
                                digest_every: 60, save_schema: nil,
                                save_digest: nil, save: nil)
    decoded = Net::Protocol.decode(line.chomp)
    assert_nil decoded[:save]
    assert_nil decoded[:save_digest]
    assert_raises(Net::Protocol::Fault, "missing save keys must fault") do
      Net::Protocol.encode(:session, session_id: "abc", seed: 1, d: 8, digest_every: 60)
    end
  end

  def test_bye_detail_is_optional_and_round_trips
    # Decision 6b: refusal BYEs carry the named refusal text so BOTH seats
    # print the SAME message; detail stays optional (link_slow precedent —
    # decode validates required shape only).
    plain = Net::Protocol.decode(Net::Protocol.encode(:bye, reason: "quit").chomp)
    assert_nil plain[:detail]
    detailed = Net::Protocol.decode(
      Net::Protocol.encode(:bye, reason: "save_digest",
                           detail: "save digest: theirs abc / computed def").chomp
    )
    assert_equal "save_digest", detailed[:reason]
    assert_match(/save digest/, detailed[:detail])
  end

  def test_decode_faults_on_garbage_unknown_and_missing_fields
    assert_raises(Net::Protocol::Fault) { Net::Protocol.decode("not json at all") }
    assert_raises(Net::Protocol::Fault) { Net::Protocol.decode("[1,2,3]") }
    assert_raises(Net::Protocol::Fault) { Net::Protocol.decode('{"m":"warp","t":1}') }
    assert_raises(Net::Protocol::Fault) { Net::Protocol.decode('{"m":"input","t":1}') }
    assert_raises(Net::Protocol::Fault) { Net::Protocol.decode('{"t":1}') }
  end

  def test_encode_faults_on_unknown_type_missing_fields_and_oversize
    assert_raises(Net::Protocol::Fault) { Net::Protocol.encode(:warp, t: 1) }
    assert_raises(Net::Protocol::Fault) { Net::Protocol.encode(:input, t: 1) }
    assert_raises(Net::Protocol::Oversize) { Net::Protocol.encode(:bye, reason: "x" * 5000) }
  end

  # --- framing ---------------------------------------------------------------

  def test_split_and_coalesced_lines_reassemble
    fb = Net::FrameBuffer.new
    assert_equal [], fb.feed('{"m":"re')
    assert fb.pending?
    assert_equal ['{"m":"ready"}'], fb.feed("ady\"}\n")
    refute fb.pending?
    two = fb.feed(%({"m":"start"}\n{"m":"input","t":1,"bits":0}\n))
    assert_equal 2, two.length
    assert_equal :start, Net::Protocol.decode(two[0])[:m]
    assert_equal :input, Net::Protocol.decode(two[1])[:m]
  end

  def test_partial_line_is_retained_across_feeds
    fb = Net::FrameBuffer.new
    assert_equal ['{"m":"ready"}'], fb.feed(%({"m":"ready"}\n{"m":"sta))
    assert_equal ['{"m":"start"}'], fb.feed("rt\"}\n")
  end

  def test_unterminated_oversize_frame_raises
    fb = Net::FrameBuffer.new
    assert_raises(Net::Protocol::Oversize) { fb.feed("x" * (Net::Protocol::MAX_LINE_BYTES + 1)) }
  end

  # --- action mask + SampledInput (sampling law) -----------------------------

  def test_bit_order_is_pinned
    # v2: :sustain APPENDS at bit 10 (decision 8); v3: :aim APPENDS at
    # bit 11 (2026-08-20) — the existing bits never move. A regression
    # here is a protocol version bump, never a silent edit.
    assert_equal %i[left right up down attack dodge special mark interact swap sustain aim],
                 Net::Protocol::ACTIONS
    assert_equal (1 << 0) | (1 << 4) | (1 << 9),
                 Net::Protocol.mask(Held.new(%i[left attack swap]))
    assert_equal 1 << 10, Net::Protocol.mask(Held.new([:sustain]))
    assert_equal 1 << 11, Net::Protocol.mask(Held.new([:aim]))
    assert_equal 0, Net::Protocol.mask(Held.new([]))
    assert_equal 4095, Net::Protocol.mask(Held.new(Net::Protocol::ACTIONS))
  end

  def test_sampled_input_mirrors_the_sampled_source_and_stays_frozen
    source = Held.new(%i[right dodge interact])
    sampled = Net::SampledInput.new(Net::Protocol.mask(source))
    Net::Protocol::ACTIONS.each do |a|
      assert_equal source.down?(a), sampled.down?(a), a.to_s
    end
    source.actions.clear # live hardware changes mid-tick...
    assert sampled.down?(:right), "...but the frozen mask never re-reads it (decision 1)"
    refute sampled.down?(:no_such_action)
    assert_nil sampled.update(5)
  end

  def test_sampled_input_drives_the_possessed_controller_duck_type
    sampled = Net::SampledInput.new(Net::Protocol.mask(Held.new([:right])))
    assert sampled.down?(:right)
    refute sampled.down?(:left)
    assert_equal 2, sampled.mask
  end
end
