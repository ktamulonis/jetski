require_relative "test_helper"
require "tmpdir"
require "fileutils"
require "stringio"
require "thor"

unless defined?(JetskiCLI)
  begin
    old_stdout = $stdout
    old_argv = ARGV.dup
    $stdout = StringIO.new
    ARGV.replace(["--version"])
    load File.expand_path("../bin/jetski", __dir__)
  ensure
    ARGV.replace(old_argv)
    $stdout = old_stdout
  end
end

require_relative "../bin/jetski_cli_helpers/shared_methods"
require_relative "../bin/jetski_cli_helpers/base"
require_relative "../bin/jetski_cli_helpers/generators/controller"
require_relative "../bin/jetski_cli_helpers/generators/model"
require_relative "../bin/jetski_cli_helpers/destroyers/controller"
require_relative "../bin/jetski_cli_helpers/destroyers/model"
require_relative "../bin/jetski_cli_helpers/generate"
require_relative "../bin/jetski_cli_helpers/destroy"

class CliTest < Minitest::Test
  class SilentCLI < JetskiCLI
    attr_reader :messages, :runs

    def initialize(*args)
      super
      @messages = []
      @runs = []
    end

  no_commands do
    def say(message)
      @messages << message
    end

    def run(cmd)
      @runs << cmd
    end
  end
  end

  def with_silenced_output
    old_stdout = $stdout
    old_stderr = $stderr
    $stdout = StringIO.new
    $stderr = StringIO.new
    yield
  ensure
    $stdout = old_stdout
    $stderr = old_stderr
  end

  def test_new_generates_app_without_running_bundle
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        cli = SilentCLI.new
        with_silenced_output { cli.new("demo") }

        assert File.directory?("demo")
        assert File.exist?("demo/app/views/layouts/application.html.erb")
        assert_includes File.read("demo/app/views/layouts/application.html.erb"), "Demo"
        assert_includes cli.runs, "cd demo && bundle install"
      end
    end
  end

  def test_routes_outputs_compiled_routes
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        FileUtils.mkdir_p("app/controllers")
        File.write("app/controllers/posts_controller.rb", <<~RUBY)
          class PostsController < Jetski::BaseController
            def index; end
          end
        RUBY

        cli = SilentCLI.new
        cli.routes

        assert cli.messages.any? { |line| line.include?("GET /posts") }
      end
    end
  end

  def test_server_uses_port_option
    cli = SilentCLI.new
    cli.define_singleton_method(:options) { { port: "1234" } }

    called = {}
    original_new = Jetski::Server.method(:new)
    Jetski::Server.define_singleton_method(:new) do |port:|
      called[:port] = port
      Struct.new(:call).new(nil)
    end

    cli.server
    assert_equal 1234, called[:port]
  ensure
    Jetski::Server.define_singleton_method(:new, original_new)
  end

  def test_generators_and_destroyers
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        FileUtils.mkdir_p("app")

        generator = JetskiCLIHelpers::Generate.new
        with_silenced_output do
          generator.resource("post", "title", "body:text")
        end

        assert File.exist?("app/models/post.rb")
        assert File.exist?("app/controllers/posts_controller.rb")
        assert File.exist?("app/views/posts/index.html.erb")

        destroyer = JetskiCLIHelpers::Destroy.new
        destroyer.db.execute("DROP TABLE IF EXISTS posts")
        destroyer.db.execute("CREATE TABLE posts (id INTEGER PRIMARY KEY)")
        with_silenced_output { destroyer.resource("post") }

        refute File.exist?("app/models/post.rb")
        refute File.exist?("app/controllers/posts_controller.rb")
        refute File.directory?("app/views/posts")
      end
    end
  end
end
