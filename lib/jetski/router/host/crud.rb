class Jetski
  class Router
    module Host
      class Crud < Base
        # Responsible for hosting auto crud routes
        attr_reader :custom_route_options
        attr_accessor :handle_controller_render
        def initialize(server, controller_routes, **server_options)
          server_options[:url] = server_options[:controller_path]
          super(server, **server_options)
          @handle_controller_render = true
        end

        def call
          super do
            @custom_route_options = all_server_options.dup.except(:action_name, :method)
            determine_action_from_url
            if handle_controller_render
              @controller_host = Jetski::Router::Host::Controller.new(server, **custom_route_options)
              @controller_host.res = res
              @controller_host.req = req
              @controller_host.fetch_controller_class
              @controller_host.call_controller
            end
          end
        end
      private
        def determine_action_from_url
          req_path = req.request_uri.path
          custom_route_options.tap do |opts|
            case req_path
            when controller_path # /posts
              # check request method for create action
              if req.request_method == "POST"
                opts[:action_name] = "create"
                opts[:method] = "POST"
              else
                opts[:action_name] = "index"
                opts[:method] = "GET"
              end
            when "#{controller_path}/new"
              opts[:action_name] = "new"
              opts[:method] = "GET"
            else
              url_param = req_path.split("#{controller_path}/")[-1]
              case
              when url_param&.match(/\d(\/edit)/)
                # Edit page
                opts[:action_name] = "edit"
                opts[:method] = "GET"
              when url_param&.match(/\d\z/)
                # matches only id 5 with no additional characters
                # Determine if show/update/destroy from request_method
                opts[:method] = req.request_method
                case req.request_method
                when "GET"
                  opts[:action_name] = "show"
                when "PUT"
                  opts[:action_name] = "update"
                when "DELETE"
                  opts[:action_name] = "destroy"
                end
              else
                @handle_controller_render = false
              end
            end
          end
        end
      end
    end
  end
end