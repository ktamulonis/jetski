# This is responsible for methods for routing in base_controller like the route class method

class Jetski
  module Helpers
    module RouteHelpers
      def route(method_name, root: false, path: nil, request_method: nil)
        @custom_route_opts ||= {}
        @custom_route_opts[method_name] = {
          method_name: method_name,
          root: root,
          path: path,
          request_method: request_method,
        }
      end
    end
  end
end