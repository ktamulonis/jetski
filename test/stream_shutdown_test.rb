require_relative "test_helper"
require "webrick"
require "socket"
require "timeout"

class StreamShutdownTest < Minitest::Test
  def test_stream_connections_do_not_block_shutdown
    port = find_available_port
    server = WEBrick::HTTPServer.new(
      Port: port,
      BindAddress: "127.0.0.1",
      Logger: WEBrick::Log.new(nil, 0),
      AccessLog: []
    )

    Jetski::Router.new(server).call

    server_thread = Thread.new { server.start }

    wait_for_server(port)
    socket = open_stream_socket(port)

    Jetski::Stream.shutdown!
    server.shutdown

    Timeout.timeout(2) { server_thread.join }
  ensure
    socket&.close
    server&.shutdown
    server_thread&.join(0.5)
    Jetski::Stream.reset_shutdown!
  end

  private

  def find_available_port
    server = TCPServer.new("127.0.0.1", 0)
    port = server.addr[1]
    server.close
    port
  end

  def wait_for_server(port)
    Timeout.timeout(2) do
      loop do
        begin
          TCPSocket.new("127.0.0.1", port).close
          break
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          sleep 0.05
        end
      end
    end
  end

  def open_stream_socket(port)
    socket = TCPSocket.new("127.0.0.1", port)
    socket.write("GET /stream HTTP/1.1\r\nHost: 127.0.0.1\r\nConnection: keep-alive\r\n\r\n")

    buffer = +""
    Timeout.timeout(2) do
      loop do
        buffer << socket.readpartial(1024)
        break if buffer.include?("\r\n\r\n") && buffer.include?(": connected")
      end
    end

    socket
  end
end
