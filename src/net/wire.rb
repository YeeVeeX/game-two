require "socket"
require "net/protocol"

module Net
  # v17 socket pump (spec Netplay spec, Qwen fold — the Windows discipline
  # is pinned): exactly ONE drain attempt per pump_reads call — IO.select
  # zero-timeout probe, then a single read_nonblock handling the spurious-
  # readability case (winsock reports readable sockets that then wait),
  # never a retry-spin; ECONNRESET/EPIPE/EOF mark the wire dead (the
  # session maps dead -> conn_lost); partial writes are retained in an
  # outbound buffer across pumps; TCP_NODELAY is verified via getsockopt
  # after set (setsockopt can fail silently).
  class Wire
    class Error < StandardError; end

    READ_BYTES = 4096

    attr_reader :dead_reason

    def self.nodelay!(socket)
      socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
      return if socket.getsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY).bool
      raise Error, "TCP_NODELAY did not stick (setsockopt failed silently)"
    end

    def initialize(socket)
      self.class.nodelay!(socket)
      @socket = socket
      @frames = FrameBuffer.new
      @outbound = +""
      @dead_reason = nil
    end

    def dead? = !@dead_reason.nil?

    # Queue one already-encoded line and attempt a flush.
    def send_line(line)
      return if dead?
      @outbound << line
      flush_writes
    end

    # ONE drain attempt; returns complete lines (possibly none). An
    # unterminated frame past MAX_LINE_BYTES kills the wire — a link that
    # never terminates a frame is dead/garbage (conn_lost taxonomy).
    def pump_reads
      return [] if dead?
      readable, = IO.select([@socket], nil, nil, 0)
      return [] unless readable&.any?
      bytes = @socket.read_nonblock(READ_BYTES, exception: false)
      return [] if bytes == :wait_readable # spurious readability — try next update
      return die(:eof) if bytes.nil?
      @frames.feed(bytes)
    rescue Protocol::Oversize
      die(:oversize)
    rescue SystemCallError, IOError
      die(:socket)
    end

    def flush_writes
      return if dead? || @outbound.empty?
      written = @socket.write_nonblock(@outbound, exception: false)
      @outbound.slice!(0, written) if written.is_a?(Integer) # :wait_writable retains all
      nil
    rescue SystemCallError, IOError
      die(:socket)
      nil
    end

    def pending_writes? = !@outbound.empty?

    def close
      @socket.close unless @socket.closed?
    rescue IOError
      nil
    end

    private

    def die(reason)
      @dead_reason ||= reason
      close
      []
    end
  end
end
