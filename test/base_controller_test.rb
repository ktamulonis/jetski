require_relative "test_helper"

class BaseControllerTest < Minitest::Test
  def test_render_text_and_json
    res = FakeResponse.new
    controller = Jetski::BaseController.new(res)
    controller.render(text: "hi")

    assert_equal "text/plain", res.content_type
    assert_equal "hi\n", res.body
    assert controller.performed_render

    res_json = FakeResponse.new
    controller_json = Jetski::BaseController.new(res_json)
    controller_json.render(json: { ok: true })

    assert_equal "application/json", res_json.content_type
    assert_equal "{\"ok\":true}", res_json.body
  end

  def test_redirect_and_cookies
    res = FakeResponse.new
    controller = Jetski::BaseController.new(res)

    controller.redirect_to("/go")
    assert controller.performed_render
    assert_equal WEBrick::HTTPStatus::Found, res.status
    assert_equal "/go", res.redirected_to

    controller.set_cookie(:token, "abc")
    controller.cookies = res.cookies
    assert_equal "abc", controller.get_cookie(:token)
  end
end
