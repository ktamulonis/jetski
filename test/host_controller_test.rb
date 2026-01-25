require_relative "test_helper"
require "tmpdir"
require "fileutils"

class HostControllerTest < Minitest::Test
  class PostsController < Jetski::BaseController
    class << self
      attr_accessor :last_params, :last_cookies
    end

    def show
      self.class.last_params = params.to_h
      self.class.last_cookies = cookies
      @title = "Hello"
    end
  end

  def test_call_controller_sets_params_and_renders
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        FileUtils.mkdir_p("app/views/layouts")
        FileUtils.mkdir_p("app/views/posts")
        File.write("app/views/layouts/application.html.erb", "<html><head></head><body><%= yield %></body></html>")
        File.write("app/views/posts/show.html.erb", "<h1><%= @title %></h1>")

        req = FakeRequest.new(
          path: "/posts/1",
          request_method: "GET",
          body: JSON.dump({ "title" => "Hi" }),
          content_type: "application/json",
          cookies: [WEBrick::Cookie.new("session", "abc")]
        )
        res = FakeResponse.new

        host = Jetski::Router::Host::Controller.new(
          nil,
          url: "/posts/:id",
          method: "GET",
          controller_classname: "PostsController",
          controller_name: "posts",
          controller_path: "/posts",
          controller_file_name: "posts_controller.rb",
          action_name: "show"
        )
        host.req = req
        host.res = res
        host.instance_variable_set(:@controller_class, PostsController)

        host.call_controller

        assert_equal "1", PostsController.last_params[:id]
        assert_equal "Hi", PostsController.last_params[:title]
        assert_equal "abc", PostsController.last_cookies.first.value
        assert_equal "text/html", res.content_type
        assert_includes res.body, "<h1>Hello</h1>"
      end
    end
  end

  def test_parses_form_encoded_body
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        FileUtils.mkdir_p("app/views/layouts")
        FileUtils.mkdir_p("app/views/posts")
        File.write("app/views/layouts/application.html.erb", "<html><head>\n</head><body><%= yield %></body></html>")
        File.write("app/views/posts/show.html.erb", "<h1>Ok</h1>")

        req = FakeRequest.new(
          path: "/posts/2",
          request_method: "POST",
          body: "title=Hello&count=2",
          content_type: "application/x-www-form-urlencoded",
          cookies: []
        )
        res = FakeResponse.new

        host = Jetski::Router::Host::Controller.new(
          nil,
          url: "/posts/:id",
          method: "POST",
          controller_classname: "PostsController",
          controller_name: "posts",
          controller_path: "/posts",
          controller_file_name: "posts_controller.rb",
          action_name: "show"
        )
        host.req = req
        host.res = res
        host.instance_variable_set(:@controller_class, PostsController)

        host.call_controller

        assert_equal "2", PostsController.last_params[:id]
        assert_equal "Hello", PostsController.last_params[:title]
        assert_equal "2", PostsController.last_params[:count]
      end
    end
  end

  def test_raw_body_raises_when_not_hash_like
    req = FakeRequest.new(
      path: "/posts/3",
      request_method: "POST",
      body: "raw-data",
      content_type: "text/plain",
      cookies: []
    )
    res = FakeResponse.new

    host = Jetski::Router::Host::Controller.new(
      nil,
      url: "/posts/:id",
      method: "POST",
      controller_classname: "PostsController",
      controller_name: "posts",
      controller_path: "/posts",
      controller_file_name: "posts_controller.rb",
      action_name: "show"
    )
    host.req = req
    host.res = res
    host.instance_variable_set(:@controller_class, PostsController)

    assert_raises(NoMethodError) { host.call_controller }
  end
end
