require_relative "test_helper"

class DatabaseInterfaceTest < Minitest::Test
  class InterfaceHost
    include Jetski::Helpers::Generic
    include Jetski::Database::Base
    include Jetski::Database::Interface
  end

  def setup
    @db = Jetski::Database::Base.db
    @db.execute("DROP TABLE IF EXISTS gadgets")
    @host = InterfaceHost.new
  end

  def test_create_table_sql_and_data_types
    sql = @host.create_table_sql(table_name: "gadget", field_names: ["name:string", "count:integer"])
    assert_includes sql, "create table gadgets"
    assert_includes sql, "name string"
    assert_includes sql, "count integer"

    assert_equal "varchar(255)", @host.sql_data_type("")
    assert_equal "varchar(255)", @host.sql_data_type("string")
    assert_equal "text", @host.sql_data_type("text")
  end

  def test_interface_create_and_add_columns
    @host.create_table_unless_exists("gadgets", "name:string")
    assert @host.table_exists?("gadgets")
    assert @host.field_exists?("gadgets", :name)

    @host.add_column_unless_exists("gadgets", :serial, "string")
    assert @host.field_exists?("gadgets", :serial)
  end
end
