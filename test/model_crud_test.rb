require_relative "test_helper"

class ModelCrudTest < Minitest::Test
  class Widget < Jetski::Model
    # Avoid namespaced test class names leaking into table names.
    def self.table_name
      "widget"
    end
  end

  def setup
    db = Widget.db
    db.execute("DROP TABLE IF EXISTS widgets")
    db.execute(<<~SQL)
      CREATE TABLE widgets (
        id INTEGER PRIMARY KEY,
        name TEXT,
        created_at TEXT
      );
    SQL
  end

  def test_create_find_all_and_destroy
    widget = Widget.create(name: "one")
    assert_equal "one", widget.name
    assert_equal 1, widget.id

    found = Widget.find(widget.id)
    assert_equal "one", found.name

    all = Widget.all
    assert_equal 1, all.size

    widget.destroy!
    assert_nil Widget.find(widget.id)
  end

  def test_destroy_all_and_delegated_helpers
    Widget.create(name: "first")
    Widget.create(name: "second")

    assert_equal 2, Widget.count
    assert_equal "first", Widget.first.name
    assert_equal "second", Widget.last.name

    Widget.destroy_all!
    assert_equal 0, Widget.count
  end
end
