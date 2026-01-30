require_relative "test_helper"

class DatabaseMigrateModelsTest < Minitest::Test
  DummyModel = Class.new do
    def self.pluralized_table_name
      "dummy_models"
    end

    def self.db_attribute_values
      [
        { name: :name, type: :string },
        { name: :count, type: :integer }
      ]
    end
  end

  def setup
    db = Jetski::Database::Base.db
    db.execute("DROP TABLE IF EXISTS dummy_models")
  end

  def test_migrate_models_creates_table_and_columns
    Jetski::Database::Interface.migrate_models([DummyModel])

    assert Jetski::Database::Interface.table_exists?("dummy_models")
    assert Jetski::Database::Interface.field_exists?("dummy_models", :name)
    assert Jetski::Database::Interface.field_exists?("dummy_models", :count)
  end
end
