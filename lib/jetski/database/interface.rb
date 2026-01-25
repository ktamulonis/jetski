# Responsibility is to wrap calls to db and make it more clean and readable.

class Jetski
  module Database
    module Interface
      extend self
      def create_table(table_name, *fields)
        db.execute create_table_sql(table_name: table_name, field_names: fields)
      end
      
      def add_column(table_name, field_name, data_type = "string")
        db.execute("ALTER TABLE #{table_name} ADD #{field_name} #{sql_data_type(data_type)}")
      end

      def create_table_unless_exists(table_name, *fields)
        create_table(table_name, *fields) if !table_exists?(table_name)
      end

      def add_column_unless_exists(table_name, field_name, data_type = nil)
        add_column(table_name, field_name, data_type) if !field_exists?(table_name, field_name)
      end

      def table_exists?(table_name)
        db.get_first_value("SELECT name FROM sqlite_master WHERE type='table' AND name=?", table_name)
      end

      def field_exists?(table_name, field_name)
        table_info = db.execute("PRAGMA table_info(#{table_name})")
        table_info.find { |d| d[1] == field_name.to_s } != nil
      end
    end
  end
end