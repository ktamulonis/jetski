ENV["JETSKI_DB"] = ":memory:"

require "minitest/autorun"
require_relative "../lib/jetski"

class ModelPatchStreamingTest < Minitest::Test
  class StreamTestModel < Jetski::Model
    def self.table_name
      "stream_test_models"
    end
  end

  def setup
    db = Jetski::Model.db

    db.execute <<~SQL
      CREATE TABLE IF NOT EXISTS stream_test_models (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        created_at TEXT
      )
    SQL

    Jetski::Events.reset!
  end

  def test_patch_emits_stream_event
    events = []

    Jetski::Events.subscribe(:model_patched) do |payload|
      events << payload
    end

    record = StreamTestModel.create(title: "before")
    StreamTestModel.patch(record.id, title: "after")

    assert_equal 1, events.size
  end
end

