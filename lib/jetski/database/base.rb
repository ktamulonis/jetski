class Jetski
  module Database
    module Base
      extend self
      extend Jetski::Helpers::Generic

      def db
        path = ENV["JETSKI_DB_PATH"].to_s
        path = File.join(Jetski.app_root, "dev.db") if path == ""
        if defined?(@@db_path) && @@db_path != path
          @@db = nil
        end
        @@db_path = path
        @@db ||= SQLite3::Database.new(path)
      end

      def create_table_sql(table_name:, field_names: [])
        table_name = pluralize_string(table_name)
        default_fields = [["created_at", "datetime"], ["updated_at", "datetime"], ["id", "integer"]]
        fields = field_names.map { |f| f.split(":") }
        all_fields = fields + default_fields
        _gen_sql = "create table #{table_name} (\n"
        _gen_sql += all_fields.map { |field, data_type| " #{field} #{data_type}" }.join(",\n")
        _gen_sql += ");\n"
        _gen_sql
      end

      def sql_data_type(str)
        case str
        when "", "string"
          "varchar(255)"
        else
          str
        end
      end
    end
  end
end
