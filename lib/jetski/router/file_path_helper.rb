class Jetski
  class Router
    module FilePathHelper
      def controller_file_paths
        Dir.glob([File.join(Jetski.app_root, 'app', 'controllers', '**', '*_controller.rb')])
      end

      def model_file_paths
        Dir.glob(File.join(Jetski.app_root, 'app', 'models', '**/*.rb'))
      end
    end
  end
end