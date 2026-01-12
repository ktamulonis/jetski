require_relative "test_helper"

class ModelInstanceDelegationTest < Minitest::Test
  def setup
    TestMessage.delete_all if TestMessage.respond_to?(:delete_all)

    @message = TestMessage.create(
      chat_id: 1,
      role: "assistant",
      content: "hello"
    )
  end

  def test_instance_patch_delegates_to_class
    updated = @message.patch(content: "delegated")

    assert_equal "delegated", updated.content
  end

  def test_instance_append_delegates_to_class
    updated = @message.append(:content, " world")

    assert_equal "hello world", updated.content
  end
end

