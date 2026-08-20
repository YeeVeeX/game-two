require "json"

module Net
  # v17 netplay protocol (spec Netplay spec): version, the pinned action
  # bit order (spec decision 1), and the line-JSON codec. Every message is
  # ONE newline-terminated JSON line, max MAX_LINE_BYTES; debuggability
  # beats binary at ~30 B/tick. Phase enforcement (a message outside its
  # phase = protocol fault) lives in Net::Session — the codec validates
  # SHAPE only.
  #
  # Fault taxonomy (decision 8 reason precedence consumes it):
  #   Fault    -> reason=protocol (malformed/unknown/missing-field/oversize
  #               ENCODE — we built a bad message, or the peer speaks wrong)
  #   Oversize -> reason=conn_lost when raised mid-stream by FrameBuffer
  #               (a frame that never terminates is a dead/garbage link).
  module Protocol
    class Fault < StandardError; end
    class Oversize < Fault; end

    VERSION = 3

    # Bit i of an input mask = ACTIONS[i] held. PINNED — changing this
    # order is a protocol version bump, never a silent edit. v2 (v18
    # decision 8): :sustain APPENDS at bit 10 — the BIT rides now, the
    # verb lands in the sustain increment; an unbound action reads false
    # on every input source, so the bit stays 0 until then. v3
    # (2026-08-20 owner order, stationary aim): :aim APPENDS at bit 11 —
    # same append-only law; the handshake's version field refuses mixed
    # builds with a NAMED line, so both seats pull before coop.
    ACTIONS = %i[left right up down attack dodge special mark interact swap sustain aim].freeze

    MAX_LINE_BYTES = 4096

    # Message vocabulary + required fields (beyond the "m" type tag).
    # Field names spell themselves except tick = "t" (the spec's INPUT{t}).
    # v2 (v18 decisions 5/8): SESSION carries the save — save_schema +
    # save_digest + save (the canonical FACTS string EXACTLY as digested,
    # or null for a fresh world; the joiner digests the RECEIVED string
    # before parsing). BYE may carry an optional `detail` (the named
    # refusal text — both seats print the SAME refusal, decision 6b).
    MESSAGES = {
      hello: %i[version ruby platform fingerprint digest_version],
      probe: %i[n],
      probe_ack: %i[n],
      session: %i[session_id seed d digest_every save_schema save_digest save],
      ready: [],
      start: [],
      input: %i[t bits],
      digest: %i[t md5],
      desync: %i[t],
      bye: %i[reason]
    }.freeze

    module_function

    # Sample an input source into the 11-bit mask — called exactly ONCE
    # per EXECUTED tick (sampling law, decision 1); the mask is the
    # authoritative record of what this seat held.
    def mask(input)
      ACTIONS.each_with_index.sum { |action, i| input.down?(action) ? 1 << i : 0 }
    end

    def encode(type, **fields)
      required = MESSAGES.fetch(type) { raise Fault, "unknown message type #{type.inspect}" }
      missing = required - fields.keys
      raise Fault, "#{type} missing #{missing.inspect}" unless missing.empty?
      line = JSON.generate({ m: type }.merge(fields)) << "\n"
      raise Oversize, "#{type} encodes to #{line.bytesize} bytes" if line.bytesize > MAX_LINE_BYTES
      line
    end

    # One complete line (no trailing newline required) -> symbolized hash
    # with :m as a Symbol. Anything malformed is a Fault.
    def decode(line)
      raise Oversize, "line is #{line.bytesize} bytes" if line.bytesize > MAX_LINE_BYTES
      msg = begin
        JSON.parse(line, symbolize_names: true)
      rescue JSON::ParserError => e
        raise Fault, "bad JSON: #{e.message}"
      end
      raise Fault, "not an object: #{line.strip}" unless msg.is_a?(Hash)
      type = msg[:m]&.to_sym
      required = MESSAGES.fetch(type) { raise Fault, "unknown message type #{msg[:m].inspect}" }
      missing = required - msg.keys
      raise Fault, "#{type} missing #{missing.inspect}" unless missing.empty?
      msg.merge(m: type)
    end
  end

  # The frozen per-tick input the lockstep sim consumes (decision 1):
  # ScriptedInput semantics — down? reads the MASK, never hardware, so
  # both machines consume identical values for the same slot by
  # construction. Holds no reference to any live input source.
  class SampledInput
    attr_reader :mask

    def initialize(mask)
      @mask = mask
    end

    def down?(action)
      i = Protocol::ACTIONS.index(action)
      return false unless i
      (@mask >> i) & 1 == 1
    end

    def update(_frame) = nil
  end

  # Buffered line framing over a byte stream (spec Netplay spec): feed
  # raw reads, get back complete lines; split and coalesced lines are
  # handled; a partial line is retained across feeds. A frame that grows
  # past MAX_LINE_BYTES without terminating raises Oversize (the caller
  # maps it to conn_lost — a link speaking garbage).
  class FrameBuffer
    def initialize
      @buf = +""
    end

    def feed(bytes)
      @buf << bytes
      lines = []
      while (i = @buf.index("\n"))
        lines << @buf.slice!(0..i).chomp("\n")
      end
      if @buf.bytesize > Protocol::MAX_LINE_BYTES
        raise Protocol::Oversize, "unterminated frame at #{@buf.bytesize} bytes"
      end
      lines
    end

    def pending? = !@buf.empty?
  end
end
