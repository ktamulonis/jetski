require_relative "test_helper"

class ModelPatchTest < Minitest::Test
  def setup
    TestMessage.delete_all if TestMessage.respond_to?(:delete_all)

    @message = TestMessage.create(
      chat_id: 1,
      role: "assistant",
      content: "hello"
    )
  end

  def test_patch_updates_attributes
    updated = TestMessage.patch(@message.id, content: "updated")

    assert_equal "updated", updated.content
  end

  def test_patch_does_not_mutate_existing_instance
    snapshot = TestMessage.last

    TestMessage.patch(snapshot.id, content: "changed")

    assert_equal "hello", snapshot.content
  end
end

