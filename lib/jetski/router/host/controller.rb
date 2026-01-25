class Jetski
  class Router
    module Host
      class Controller < Base
        # Responsibility is to host the route with methods to route url to controller action
        # URL -> Controller#Action
        # Uses controller class name and action name to serve request
        
        def initialize(server, **server_options)
          super(server, **server_options)
        end

        def call
          super do
            fetch_controller_class if errors.empty?
            call_controller if errors.empty?
          end
        end

        def call_controller
          controller = controller_class.new(res)
          controller.action_name = action_name
          controller.controller_name = controller_name
          controller.controller_path = controller_path
          params_hash = {}
          id_crud_actions = ["show", "edit", "destroy"]
          if id_crud_actions.include?(action_name)
            # Need to set id value from url. if available.
            auto_id_param = req.path.split("#{controller_path}/")[-1].split("/")[0]
            params_hash[:id] ||= auto_id_param
          end
          if req.body
            parsed_body = parse_body(req.body, req.content_type)
            params_hash = parsed_body.merge(params_hash)
          end

          # TODO: Need to support deep object structuring.
          controller.params = OpenStruct.new(params_hash)
          controller.cookies = req.cookies
          controller.send(action_name)
          if !controller.performed_render && (request_method.upcase == "GET")
            controller.render
          end
        end
      private
        def parse_body(body, content_type = '')
          case content_type
          when "application/x-www-form-urlencoded"
            Rack::Utils.parse_nested_query body
          when "application/json"
            JSON.parse(body)
          else
            body
          end
        end
      end
    end
  end
end