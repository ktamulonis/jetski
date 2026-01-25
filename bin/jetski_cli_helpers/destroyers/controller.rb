module JetskiCLIHelpers
  module Destroyers
    module Controller
      def destroy_controller(name)
        controller_name = pluralize_string(name)
        controller_file_path = "app/controllers/#{controller_name}_controller.rb"
        remove_file(controller_file_path)
        view_folder = "app/views/#{controller_name}"
        remove_dir(view_folder)
      end
    end
  end
end