require_relative "test_helper"
require "webrick"

class RouterStreamTest < Minitest::Test
  def test_stream_route_is_mounted
    server = WEBrick::HTTPServer.new(
      Port: 0,
      Logger: WEBrick::Log.new(nil, 0),
      AccessLog: []
    )

    Jetski::Router.new(server).call

    mount_tab = server.instance_variable_get(:@mount_tab)
    tab = mount_tab.instance_variable_get(:@tab)

    assert tab.key?("/stream"), "Expected /stream to be mounted, got #{tab.keys.inspect}"
  ensure
    server&.shutdown
  end
end
