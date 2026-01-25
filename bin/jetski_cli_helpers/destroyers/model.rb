module JetskiCLIHelpers
  module Destroyers
    module Model
      def destroy_model(name)
        model_file_path = "app/models/#{name}.rb"
        remove_file(model_file_path)
        table_name = pluralize_string(name)
        remove_table_sql = "DROP TABLE #{table_name}"
        db.execute(remove_table_sql)
      end
    end
  end
end