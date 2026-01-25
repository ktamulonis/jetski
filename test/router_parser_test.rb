require_relative "test_helper"
require "tmpdir"
require "fileutils"

class RouterParserTest < Minitest::Test
  def test_compile_routes_for_crud_and_custom
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        FileUtils.mkdir_p("app/controllers")
        File.write("app/controllers/posts_controller.rb", <<~RUBY)
          class PostsController < Jetski::BaseController
            route :home, root: true
            route :custom, path: "/special", request_method: "POST"

            def index; end
            def show; end
            def home; end
            def custom; end
          end
        RUBY

        routes = Jetski::Router::Parser.compile_routes
        show_route = routes.find { |r| r[:action_name] == "show" }
        index_route = routes.find { |r| r[:action_name] == "index" }
        home_route = routes.find { |r| r[:action_name] == "home" }
        custom_route = routes.find { |r| r[:action_name] == "custom" }

        assert_equal "/posts/:id", show_route[:url]
        assert_equal "GET", show_route[:method]
        assert_equal "/posts", index_route[:url]
        assert_equal "GET", index_route[:method]
        assert_equal "/", home_route[:url]
        assert_equal "GET", home_route[:method]
        assert_equal "/special", custom_route[:url]
        assert_equal "POST", custom_route[:method]
      end
    end
  end
end
