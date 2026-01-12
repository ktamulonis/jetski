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
end

