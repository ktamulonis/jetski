require_relative "test_helper"
require "json"

class StreamPayloadTest < Minitest::Test
  def test_broadcast_formats_sse_data
    captured = nil
    writer = ->(data) { captured = data }

    Jetski::Stream.subscribe(&writer)
    Jetski::Stream.broadcast(type: "model_append", delta: "hi")

    assert captured.start_with?("data:")
    parsed = JSON.parse(captured.sub("data: ", "").strip)
    assert_equal "hi", parsed["delta"]

  ensure
    Jetski::Stream.unsubscribe(writer)
  end
end

