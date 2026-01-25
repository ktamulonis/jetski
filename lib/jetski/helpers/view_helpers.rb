class Jetski
  module Helpers
    module ViewHelpers
      # Expecting a relative path.
      def render(partial_path, **locals)
        path_to_file = File.join(Jetski.app_root, 'app/views', 
          path_to_controller, "_#{partial_path}.html.erb")
        content = File.read(path_to_file)
        bind = binding
        locals.each do |k, v| 
          bind.local_variable_set k, v
        end
        template = ERB.new(content)
        template.result(bind)
      end

      # link_to "New post", "/posts/new"
      def link_to(link_text, url, **html_opts)
        # TODO: Allow passing block to link_to
        "<a href='#{url}' #{format_html_options(**html_opts)}>#{link_text}</a>"
      end

      # button_to("Click me", class: "cool-btn")
      def button_to(button_text, url = nil, **html_opts)
        if url
          _method = html_opts[:method] || 'POST'
          # Create form with button inside lol
          _form = "<form action='#{url}' method='#{_method}'>"
          _form += "<button type='submit' #{format_html_options(**html_opts)}>#{button_text}</button>"
          _form += "</form>"
          _form
        else
          _button = "<button #{format_html_options(**html_opts)}>#{button_text}</button>"
        end
      end

      def input_tag(input_name = nil, **html_opts)
        html_opts[:name] ||= input_name
        "<input #{format_html_options(**html_opts)}>"
      end

      def label_tag(text, **html_opts)
        "<label #{format_html_options(**html_opts)}>#{text}</label>"
      end

      def textarea_tag(name = nil, value = nil, **html_opts)
        html_opts[:name] ||= name
        value ||= html_opts[:value]
        "<textarea #{format_html_options(**html_opts.except(:value))}>#{value}</textarea>"
      end

      def image_tag(image_path, **html_opts)
        abs_url = process_url(image_path)
        "<img src='#{abs_url}' #{format_html_options(**html_opts)}></img>"
      end

      def favicon_tag(url, **html_opts)
        abs_url = process_url(url)
        "<link rel='icon' type='image/x-icon' #{format_html_options(**html_opts)} href='#{abs_url}'>"
      end

      def stylesheet_tag(url, **html_opts)
        abs_url = process_url(url)
        "<link rel='stylesheet' #{format_html_options(**html_opts)} href='#{abs_url}'>"
      end

      def javascript_include_tag(url, **html_opts)
        abs_url = process_url(url)
        "<script src='#{abs_url}' #{format_html_options(**html_opts)}></script>"
      end

      def javascript_tag(**html_opts)
        "<script #{format_html_options(**html_opts)}>#{yield}</script>"
      end

      def truncate(text, limit)
        text[0..limit]
      end

      def format_html_options(**html_opts)
        html_opts.map do |k, v|
          formatted_key = k.to_s.gsub("_", "-")
          "#{formatted_key}='#{v}'"
        end.join(" ")
      end
    private
      # TODO: could move this to a sharable method.
      def process_url(url)
        if url[0] == '/'
          url
        else
          "/#{url}"
        end
      end
    end
  end
end