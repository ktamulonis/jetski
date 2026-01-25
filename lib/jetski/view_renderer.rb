class Jetski
  class ViewRenderer
    include Jetski::Helpers::ViewHelpers
    extend Jetski::Helpers::Delegatable
    
    attr_reader :errors, :controller
    delegate :res, :action_name, :controller_path, to: :controller
    
    def initialize(controller)
      @controller = controller
      @errors = []
    end

    def call
      res.content_type = "text/html"
      _rendered_view = perform_view_render
      sanitized_view_render = _rendered_view.split("\n").map(&:strip).join("\n")
      view_render = sanitized_view_render.gsub("\n</head>", "#{content_for_head}\n</head>")
      return error_screen if errors.any?
      res.body = view_render
    end
  private
    def error_screen
      # TODO: Make better error screen
      res.body = "<h1> Errors: #{errors.map {|e| e }.join(", ")} </h1>"
    end

    def perform_view_render
      template_content = File.read(template_path)
      layout_content = File.read(layout_path)
      process_erb(layout_content) { process_erb(template_content) }
    end

    def process_erb(content)
      template = ERB.new(content)

      grab_instance_variables
      template.result(binding)
    rescue => e
      # TODO: Add a better error screen like rails show a snapshot of the template and get the line number of error
      # Also using template error doesnt account for errors inside of partials so need a new way of getting this
      @errors << "Error in #{local_template_path}"
      @errors << e
      nil
    end

    def grab_instance_variables
      variables_from_controller = controller.instance_variables.filter { |var| !Jetski::BaseController::RESERVED_INSTANCE_VARIABLES.include?(var) }
      variables_from_controller.each do |inst_var|
        value = controller.instance_variable_get(inst_var)
        instance_variable_set(inst_var, value)
      end
    end

    def content_for_head
      _content_for_head = ''

      application_css_file = File.join(assets_folder, "stylesheets", "application.css")
      if File.exist? application_css_file
        _content_for_head += "<link rel='stylesheet' href='/application.css'>\n"
      end

      controller_css_file = File.join(assets_folder, "stylesheets", "#{path_to_controller}.css")
      if File.exist? controller_css_file
        _content_for_head += "<link rel='stylesheet' href='/#{path_to_controller}.css'>\n"
      end
      
      application_js_file = File.join(assets_folder, "javascript", "application.js")
      if File.exist? application_js_file
        _content_for_head += "<script src='/application.js' defer></script>\n"
      end

      controller_js_file = File.join(assets_folder, "javascript", "#{path_to_controller}.js")
      if File.exist? controller_js_file
        _content_for_head += "<script src='/#{path_to_controller}.js' defer></script>\n"
      end

      # Add reactive form JS code
      _content_for_head += "<script src='/reactive-form.js' defer></script>\n"

      _content_for_head
    end
    
    def views_folder 
      File.join(Jetski.app_root, 'app/views')
    end

    def assets_folder
      File.join(Jetski.app_root, 'app/assets')
    end

    def layout_path
      File.join(views_folder, "layouts/application.html.erb")
    end

    def template_path
      File.join(views_folder, local_template_path)
    end

    def local_template_path
      File.join(path_to_controller, "#{action_name}.html.erb")
    end

    def path_to_controller 
      controller_path[1..-1]
    end
  end
end