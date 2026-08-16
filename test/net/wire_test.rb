require_relative "../test_helper"
require "net/wire"

# v17 increment 5 — the socket pump over REAL loopback TCP (127.0.0.1
# explicitly: no firewall prompt, CI-safe). No threads: both ends live in
# this process and are pumped synchronously; every wait is a capped loop.
class WireTest < Minitest::Test
  def setup
    server = TCPServer.new("127.0.0.1", 0)
    @client = TCPSocket.new("127.0.0.1", server.addr[1])
    @accepted = server.accept
    server.close
  end

  def teardown
    [@client, @accepted].each do |s|
      s.close unless s.closed?
    rescue IOError
      nil
    end
  end

  # Bounded pump: one drain attempt per iteration (the live discipline),
  # capped so a delivery hiccup fails loudly instead of hanging.
  def drain(wire, cap: 50)
    got = []
    cap.times do
      got.concat(wire.pump_reads)
      return got unless got.empty?
      return got if wire.dead?
      sleep 0.001
    end
    got
  end

  def test_nodelay_is_set_and_verified
    Net::Wire.new(@client)
    assert @client.getsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY).bool,
           "the wire must verify NODELAY stuck (setsockopt can fail silently)"
  end

  def test_line_round_trip_both_directions
    a = Net::Wire.new(@accepted)
    c = Net::Wire.new(@client)
    c.send_line(%({"m":"ready"}\n))
    assert_equal ['{"m":"ready"}'], drain(a)
    a.send_line(%({"m":"start"}\n))
    assert_equal ['{"m":"start"}'], drain(c)
    refute a.dead?
    refute c.dead?
  end

  def test_split_delivery_reassembles_across_pumps
    a = Net::Wire.new(@accepted)
    @client.write(%({"m":"re))
    @client.flush
    assert_equal [], drain(a, cap: 3), "half a frame is retained, not delivered"
    @client.write(%(ady"}\n{"m":"start"}\n))
    assert_equal ['{"m":"ready"}', '{"m":"start"}'], drain(a)
  end

  def test_peer_close_reads_as_eof_death
    a = Net::Wire.new(@accepted)
    @client.close
    50.times do
      a.pump_reads
      break if a.dead?
      sleep 0.001
    end
    assert a.dead?
    assert_equal :eof, a.dead_reason
    assert_equal [], a.pump_reads, "a dead wire pumps nothing"
  end

  def test_unterminated_oversize_frame_kills_the_wire
    a = Net::Wire.new(@accepted)
    @client.write("x" * (Net::Protocol::MAX_LINE_BYTES + 1000))
    @client.flush
    50.times do
      a.pump_reads
      break if a.dead?
      sleep 0.001
    end
    assert_equal :oversize, a.dead_reason,
                 "a frame that never terminates is a dead/garbage link (conn_lost taxonomy)"
  end

  def test_writing_into_a_closed_peer_marks_the_wire_dead
    c = Net::Wire.new(@client)
    @accepted.close
    30.times do
      c.send_line(%({"m":"ready"}\n))
      break if c.dead?
      sleep 0.001
    end
    assert c.dead?
    assert_equal :socket, c.dead_reason
    c.send_line(%({"m":"ready"}\n)) # no raise after death
  end
end
