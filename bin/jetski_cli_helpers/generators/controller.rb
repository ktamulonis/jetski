module JetskiCLIHelpers
  module Generators
    module Controller
      def generate_controller(name, *actions, **extra_options)
        field_names = extra_options[:field_names]
        @name = name
        @controller_name = pluralize_string(name)

        controller_file_path = "app/controllers/#{@controller_name}_controller.rb"
        
        @controller_class_name = @controller_name.split("_").map(&:capitalize).join
        @model_class_name = @name.capitalize # post -> Post
        @field_names = field_names
        @actions = actions

        template "controllers/controller.rb.erb", controller_file_path
        
        actions.each do |action_name|
          if !["create", "create", "update", "destroy"].include?(action_name)
            empty_directory("app/views/#{@controller_name}")
            @path_to_view = "app/views/#{@controller_name}/#{action_name}.html.erb"
            template_name = if ["new", "show", "edit", "index"].include?(action_name)
              action_name
            else
              "default"
            end  
            @action_name = action_name
            template "controllers/views/#{template_name}.html.erb", @path_to_view
            say "🌊 View your new page at http://localhost:8000/#{@controller_name}/#{action_name}"
          end
        end
      end
    end
  end
end