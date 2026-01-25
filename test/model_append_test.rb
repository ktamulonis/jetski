require_relative "test_helper"

class ModelAppendTest < Minitest::Test
  def setup
    TestMessage.delete_all if TestMessage.respond_to?(:delete_all)

    @message = TestMessage.create(
      chat_id: 1,
      role: "assistant",
      content: "Hello"
    )
  end

  def test_append_adds_to_existing_field
    updated = TestMessage.append(@message.id, :content, " world")

    assert_equal "Hello world", updated.content
  end

  def test_append_handles_nil_field
    message = TestMessage.create(
      chat_id: 1,
      role: "assistant",
      content: nil
    )

    updated = TestMessage.append(message.id, :content, "Hi")

    assert_equal "Hi", updated.content
  end

  def test_append_emits_event_and_broadcast_payload
    TestMessage.delete_all if TestMessage.respond_to?(:delete_all)
    message = TestMessage.create(
      chat_id: 1,
      role: "assistant",
      content: "Hello"
    )

    events = []
    Jetski::Events.reset!
    Jetski::Events.subscribe(:model_appended) { |payload| events << payload }

    calls = []
    original = Jetski::Stream.method(:broadcast)
    Jetski::Stream.define_singleton_method(:broadcast) { |payload| calls << payload }

    TestMessage.append(message.id, :content, " world")

    assert_equal 1, calls.size
    assert_equal(
      {
        type: "model_append",
        model: "TestMessage",
        id: message.id,
        attribute: :content,
        delta: " world"
      },
      calls.first
    )

    assert_equal 1, events.size
    assert_equal "TestMessage", events.first[:model]
    assert_equal message.id, events.first[:id]
    assert_equal :content, events.first[:attribute]
    assert_equal " world", events.first[:delta]
  ensure
    Jetski::Stream.define_singleton_method(:broadcast, original)
  end
end
