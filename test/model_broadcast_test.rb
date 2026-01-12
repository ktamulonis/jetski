require_relative "test_helper"

class ModelBroadcastTest < Minitest::Test
  def setup
    TestMessage.delete_all if TestMessage.respond_to?(:delete_all)

    @message = TestMessage.create(
      chat_id: 1,
      role: "assistant",
      content: "hello"
    )
  end

  def test_patch_triggers_stream_broadcast
    calls = []

    Jetski::Stream.stub :broadcast, ->(payload) { calls << payload } do
      TestMessage.patch(@message.id, content: "hi")
    end

    assert_equal 1, calls.size

    payload = calls.first
    assert_equal "TestMessage", payload[:model]
    assert_equal @message.id, payload[:id]
    assert_equal({ content: "hi" }, payload[:changes])
  end
end

