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

      server = WEBrick::HTTPServer.new(Port: port)

      # Router EXPECTS the server instance
      Jetski::Router.new(server).call

      trap("INT") { server.shutdown }
      server.start
    end
  end
end

