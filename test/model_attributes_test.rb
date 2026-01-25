require_relative "test_helper"

class ModelAttributesTest < Minitest::Test
  class Article < Jetski::Model
    attributes :title, body: :text
  end

  class ColumnThing < Jetski::Model
    # Avoid namespaced test class names leaking into table names.
    def self.table_name
      "columnthing"
    end
  end

  def setup
    db = ColumnThing.db
    db.execute("DROP TABLE IF EXISTS columnthings")
    db.execute(<<~SQL)
      CREATE TABLE columnthings (
        id INTEGER PRIMARY KEY,
        title TEXT
      );
    SQL
  end

  def test_attributes_define_accessors_and_names
    article = Article.new(title: "Hi", body: "Body")
    assert_equal "Hi", article.title
    assert_equal "Body", article.body

    names = Article.attribute_names
    assert_includes names, :title
    assert_includes names, :body
    assert_includes names, :created_at
    assert_includes names, :updated_at
    assert_includes names, :id

    db_attrs = Article.db_attribute_values
    assert_equal({ name: :title, type: :string }, db_attrs.first)
    assert_includes db_attrs, { name: :body, type: :text }
  end

  def test_column_names_and_define_attribute_methods
    names = ColumnThing.column_names
    assert_includes names, "id"
    assert_includes names, "title"

    ColumnThing.define_attribute_methods(%i[id title])
    record = ColumnThing.new(id: 1, title: "Hello")
    assert_equal "Hello", record.title
  end
end
