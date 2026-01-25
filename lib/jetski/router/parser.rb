class Jetski
  class Router
    module Parser
      include Jetski::Router::FilePathHelper
      extend self
      def compile_routes
        auto_found_routes = []
        controller_file_paths.each do |file_path|
          require_relative file_path
          controller_file_name = file_path.split('app/controllers')[1]
          controller_path = controller_file_name.gsub(/_controller.rb/, '')
          controller_name = controller_path.split("/").last
          controller_classname = controller_path
            .split("/")
            .reject(&:empty?)
            .map(&:capitalize)
            .map { |c| c.split("_").map(&:capitalize).join }
            .join("::") + "Controller"
          controller_class = Module.const_get(controller_classname)
          action_names = controller_class.instance_methods(false)
          base_opts = { 
            controller_classname: controller_classname, 
            controller_name: controller_name,
            controller_path: controller_path,
            controller_file_name: controller_file_name,
          }
          route_opts_hash = controller_class.instance_variable_get(:@custom_route_opts) || {}
          action_names.each do |action_name|
            action_name = action_name.to_s
            route_opts = route_opts_hash.fetch(action_name.to_sym, {})
            custom_request_method = route_opts.fetch(:request_method, nil)
            is_root = route_opts.fetch(:root, nil)
            custom_path = route_opts.fetch(:path, nil)
            
            url_to_use = proc do |url|
              if is_root
                "/"
              elsif custom_path
                custom_path
              else
                url
              end
            end
            
            case action_name
            when "new"
              auto_found_routes << base_opts.merge({
                url: url_to_use.call(controller_path + "/new"),
                method: "GET",
                action_name: action_name,
              })
            when "create"
              auto_found_routes << base_opts.merge({
                url: controller_path,
                method: "POST",
                action_name: action_name,
              })
            when "show"
              auto_found_routes << base_opts.merge({
                url: controller_path + "/:id",
                method: "GET",
                action_name: action_name,
              })
            when "edit"
              auto_found_routes << base_opts.merge({
                url: controller_path + "/:id/edit",
                method: "GET",
                action_name: action_name,
              })
            when "update"
              auto_found_routes << base_opts.merge({
                url: controller_path + "/:id",
                method: "PUT",
                action_name: action_name,
              })
            when "destroy"
              auto_found_routes << base_opts.merge({
                url: controller_path + "/:id",
                method: "DELETE",
                action_name: action_name,
              })
            when "index"
              auto_found_routes << base_opts.merge({
                url: url_to_use.call(controller_path),
                method: "GET",
                action_name: action_name,
              })
            else
              url_to_use = if is_root
                "/"
              elsif custom_path
                custom_path
              else
                url_friendly_action_name = action_name.split("_").join("-")
                controller_path + "/#{url_friendly_action_name}"
              end

              auto_found_routes << base_opts.merge({
                url: url_to_use,
                method: custom_request_method || "GET",
                action_name: action_name,
              })
            end
          end
        end
        auto_found_routes
      end
    end
  end
end