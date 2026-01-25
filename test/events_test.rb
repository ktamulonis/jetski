require_relative "test_helper"

class EventsTest < Minitest::Test
  def setup
    Jetski::Events.reset!
  end

  def test_subscribe_and_publish
    payloads = []
    Jetski::Events.subscribe(:custom) { |payload| payloads << payload }

    Jetski::Events.publish(:custom, { ok: true })

    assert_equal 1, payloads.size
    assert_equal({ ok: true }, payloads.first)
  end
end
