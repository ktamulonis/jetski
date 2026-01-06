# test/family_associations_test.rb
require_relative "test_helper"

class FamilyAssociationsTest < Minitest::Test
  def setup
    Chat.destroy_all!
    Message.destroy_all!
  end

  def test_schema_inferred_parents
    assert_equal({ chat: Chat }, Message.parents)
  end

  def test_schema_inferred_kids
    assert_equal({ messages: Message }, Chat.kids)
  end

  def test_family_membership
    family = Chat.family
    assert_includes family, Chat
    assert_includes family, Message
    assert_equal 2, family.size
  end

  def test_instance_level_child_access
    chat = Chat.create(title: "Test Chat")
    Message.create(chat_id: chat.id, content: "hello world")

    messages = chat.messages
    assert_equal 1, messages.size
    assert_equal "hello world", messages.first.content
  end

  def test_multiple_children
    chat = Chat.create(title: "Multi")

    Message.create(chat_id: chat.id, content: "one")
    Message.create(chat_id: chat.id, content: "two")

    contents = chat.messages.map(&:content)
    assert_equal ["one", "two"], contents
  end
  
  def test_instance_level_parent_access
    chat = Chat.create(title: "Parent Chat")
    msg  = Message.create(chat_id: chat.id, content: "hi")

    parent = msg.chat

    refute_nil parent
    assert_equal chat.id, parent.id
    assert_equal "Parent Chat", parent.title
  end

  def test_parent_access_returns_nil_when_fk_missing
    msg = Message.create(content: "orphan")

    assert_nil msg.chat
  end

end

