require_relative "test_helper"

class StreamSubscriptionTest < Minitest::Test
  def test_subscribe_and_unsubscribe
    received = []
    writer = ->(data) { received << data }

    Jetski::Stream.subscribe(&writer)
    Jetski::Stream.broadcast(test: "hello")

    assert_equal 1, received.size
    assert_includes received.first, "hello"

    Jetski::Stream.unsubscribe(writer)
    Jetski::Stream.broadcast(test: "bye")

    assert_equal 1, received.size
  end
end

