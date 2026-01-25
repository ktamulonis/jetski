require_relative "test_helper"
require "tmpdir"
require "fileutils"

class ViewRendererTest < Minitest::Test
  class ViewTestController < Jetski::BaseController
  end

  def test_renders_layout_and_injects_assets
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        FileUtils.mkdir_p("app/views/layouts")
        FileUtils.mkdir_p("app/views/posts")
        FileUtils.mkdir_p("app/assets/stylesheets")
        FileUtils.mkdir_p("app/assets/javascript")
        File.write("app/views/layouts/application.html.erb", "<html><head>\n</head><body><%= yield %></body></html>")
        File.write("app/views/posts/index.html.erb", "<div><%= @message %></div>")
        File.write("app/assets/stylesheets/application.css", "body { }")
        File.write("app/assets/javascript/application.js", "console.log('hi');")

        res = FakeResponse.new
        controller = ViewTestController.new(res)
        controller.action_name = "index"
        controller.controller_path = "/posts"
        controller.instance_variable_set(:@message, "Hello")

        Jetski::ViewRenderer.new(controller).call

        assert_equal "text/html", res.content_type
        assert_includes res.body, "<div>Hello</div>"
        assert_includes res.body, "<link rel='stylesheet' href='/application.css'>"
        assert_includes res.body, "<script src='/application.js' defer></script>"
        assert_includes res.body, "<script src='/reactive-form.js' defer></script>"
      end
    end
  end
end
