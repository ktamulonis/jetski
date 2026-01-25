require_relative "test_helper"

class HostCrudTest < Minitest::Test
  def test_determine_action_from_url
    host = Jetski::Router::Host::Crud.new(
      nil,
      [],
      url: "/posts",
      method: "GET",
      controller_classname: "PostsController",
      controller_name: "posts",
      controller_path: "/posts",
      controller_file_name: "posts_controller.rb"
    )
    host.req = FakeRequest.new(path: "/posts/5", request_method: "GET")
    host.res = FakeResponse.new
    host.instance_variable_set(:@custom_route_options, host.instance_variable_get(:@all_server_options).dup)

    host.send(:determine_action_from_url)

    opts = host.instance_variable_get(:@custom_route_options)
    assert_equal "show", opts[:action_name]
    assert_equal "GET", opts[:method]
  end

  def test_determine_action_from_url_for_edit
    host = Jetski::Router::Host::Crud.new(
      nil,
      [],
      url: "/posts",
      method: "GET",
      controller_classname: "PostsController",
      controller_name: "posts",
      controller_path: "/posts",
      controller_file_name: "posts_controller.rb"
    )
    host.req = FakeRequest.new(path: "/posts/10/edit", request_method: "GET")
    host.res = FakeResponse.new
    host.instance_variable_set(:@custom_route_options, host.instance_variable_get(:@all_server_options).dup)

    host.send(:determine_action_from_url)

    opts = host.instance_variable_get(:@custom_route_options)
    assert_equal "edit", opts[:action_name]
    assert_equal "GET", opts[:method]
  end

  def test_determine_action_from_url_unhandled_path
    host = Jetski::Router::Host::Crud.new(
      nil,
      [],
      url: "/posts",
      method: "GET",
      controller_classname: "PostsController",
      controller_name: "posts",
      controller_path: "/posts",
      controller_file_name: "posts_controller.rb"
    )
    host.req = FakeRequest.new(path: "/posts/abc", request_method: "GET")
    host.res = FakeResponse.new
    host.instance_variable_set(:@custom_route_options, host.instance_variable_get(:@all_server_options).dup)

    host.send(:determine_action_from_url)

    assert_equal false, host.handle_controller_render
  end
end
