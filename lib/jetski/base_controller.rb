# This is the base controller of the library
class Jetski
  class BaseController
    RESERVED_INSTANCE_VARIABLES = [
        :@res, :@performed_render, :@action_name, 
        :@controller_name, :@controller_path, :@cookies
    ]

    include Jetski::Frontend::JavascriptHelpers
    extend Jetski::Helpers::RouteHelpers
    attr_accessor :action_name, :controller_name, :controller_path, 
      :params, :cookies
    attr_reader :res, :performed_render
    attr_writer :root, :path, :request_method

    def initialize(res)
      @res = res
      @performed_render = false
    end

    # Method to render matching view with controller_name/action_name
    def render(**args)
      @performed_render = true
      request_status = args[:status] || 200
      res.status = request_status
      if args[:text]
        res.content_type = "text/plain"
        res.body = "#{args[:text]}\n"
        return
      end

      if args[:json]
        res.content_type = "application/json"
        res.body = args[:json].to_json
        return
      end

      ViewRenderer.new(self).call
    end

    def redirect_to(url)
      @performed_render = true
      res.set_redirect(WEBrick::HTTPStatus::Found, url)
    end

    def set_cookie(name, value)
      res.cookies.push WEBrick::Cookie.new(name.to_s, value || "")
    end

    def get_cookie(name)
      cookies&.find { |c| c.name == name.to_s }&.value
    end
  end
end