require_relative "test_helper"
require "tmpdir"
require "fileutils"

require "thor"
require_relative "../bin/jetski_cli_helpers/shared_methods"
require_relative "../bin/jetski_cli_helpers/base"
require_relative "../bin/jetski_cli_helpers/database"

class CliDatabaseTest < Minitest::Test
  class InterfaceHost
    include Jetski::Helpers::Generic
    include Jetski::Database::Base
    include Jetski::Database::Interface
  end

  class DatabaseCLI < JetskiCLIHelpers::Database
    attr_reader :messages

    def initialize(*args)
      super
      @messages = []
    end

    no_commands do
      def say(message)
        @messages << message
      end
    end
  end

  def setup
    @host = InterfaceHost.new
  end

  def test_seed_when_file_missing
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        cli = DatabaseCLI.new
        cli.seed
        assert cli.messages.any? { |m| m.include?("No seed file") }
      end
    end
  end

  def test_seed_loads_file
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        File.write("seed.rb", "SEED_WAS_LOADED = true")
        cli = DatabaseCLI.new

        begin
          cli.seed
          assert Object.const_defined?(:SEED_WAS_LOADED)
        ensure
          Object.send(:remove_const, :SEED_WAS_LOADED) if Object.const_defined?(:SEED_WAS_LOADED)
        end
      end
    end
  end

  def test_migrate_creates_table_and_columns
    dummy_model = Class.new do
      def self.pluralized_table_name
        "dummy_models"
      end

      def self.db_attribute_values
        [{ name: :name, type: :string }]
      end
    end

    db = Jetski::Database::Base.db
    db.execute("DROP TABLE IF EXISTS dummy_models")

    cli = DatabaseCLI.new

    original_call = Jetski::Autoloader.method(:call)
    original_subclasses = Jetski::Model.method(:subclasses)

    begin
      Jetski::Autoloader.define_singleton_method(:call) { nil }
      Jetski::Model.define_singleton_method(:subclasses) { [dummy_model] }

      cli.migrate
    ensure
      Jetski::Autoloader.define_singleton_method(:call, original_call)
      Jetski::Model.define_singleton_method(:subclasses, original_subclasses)
    end

    table = db.get_first_value("SELECT name FROM sqlite_master WHERE type='table' AND name='dummy_models'")
    assert_equal "dummy_models", table
    assert @host.field_exists?("dummy_models", :name)
  end
end
