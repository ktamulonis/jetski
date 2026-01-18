require "webrick"

module Jetski
  class Server
    attr_reader :port

    def initialize(port: 8000)
      @port = Integer(port)
    rescue ArgumentError, TypeError
      raise ArgumentError, "Port must be an integer (got #{port.inspect})"
    end

    def call
      start_webrick
    end

    private

    def start_webrick
      Jetski::Autoloader.call
      Jetski::Stream.reset_shutdown!

      server = WEBrick::HTTPServer.new(Port: port)

      # Router EXPECTS the server instance
      Jetski::Router.new(server).call

      trap("INT") do
        Jetski::Stream.signal_shutdown
      end

      Thread.new do
        sleep 0.01 until Jetski::Stream.shutdown_signaled?
        Jetski::Stream.shutdown!
        server.shutdown
      end
      server.start
    end
  end
end
