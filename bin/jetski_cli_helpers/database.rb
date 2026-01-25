module JetskiCLIHelpers
  class Database < Base
    desc "migrate", "Create, load, and patch DB from models"
    def migrate
      Jetski::Autoloader.call
      Jetski::Model.subclasses.each do |model|
        table_name = model.pluralized_table_name
        create_table_unless_exists(table_name)
        model.db_attribute_values
          .each { |obj| add_column_unless_exists(table_name, obj[:name], obj[:type]) }
      end
    end

    desc "seed", "Seeds the database with records created from seed file"
    def seed
      seed_file_path = './seed.rb'
      if File.exist?(seed_file_path)
        Jetski::Autoloader.call
        load(seed_file_path)
      else
        say "No seed file is specified create one in your app ./seed.rb"
      end
    end
  end
end