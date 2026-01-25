require_relative "test_helper"

class HostBaseTest < Minitest::Test
  def test_mismatched_request_url_sets_404
    server = FakeServer.new
    host = Jetski::Router::Host::Base.new(
      server,
      url: "/good",
      method: "GET",
      controller_file_name: "posts_controller.rb",
      controller_path: "/posts",
      controller_classname: "PostsController",
      controller_name: "posts",
      action_name: "index"
    )

    host.call {}

    req = FakeRequest.new(path: "/bad", request_method: "GET")
    res = FakeResponse.new
    server.mounts["/good"].call(req, res)

    assert_equal 404, res.status
    assert_equal "Not Found", res.body
  end
end
