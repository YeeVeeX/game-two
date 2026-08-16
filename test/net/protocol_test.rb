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

  def test_every_message_type_round_trips
    examples = {
      hello: { version: 1, ruby: "3.4.10", platform: "x64-mingw-ucrt",
               fingerprint: "abc123", digest_version: 1 },
      probe: { n: 3 }, probe_ack: { n: 3 },
      session: { session_id: "s-42", seed: 42, d: 8, digest_every: 60 },
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
    line = Net::Protocol.encode(:input, t: 999_999, bits: 1023)
    assert_operator line.bytesize, :<=, 40, "per-tick cost is the whole transport bet"
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
    assert_equal %i[left right up down attack dodge special mark interact swap],
                 Net::Protocol::ACTIONS
    # left = bit 0, attack = bit 4, swap = bit 9 — a regression here is a
    # protocol version bump, never a silent edit.
    assert_equal (1 << 0) | (1 << 4) | (1 << 9),
                 Net::Protocol.mask(Held.new(%i[left attack swap]))
    assert_equal 0, Net::Protocol.mask(Held.new([]))
    assert_equal 1023, Net::Protocol.mask(Held.new(Net::Protocol::ACTIONS))
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
