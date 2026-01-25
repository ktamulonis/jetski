class Jetski
  module Frontend
    module JavascriptHelpers
      def reactive_text_area(path, **opts)
        css_classes = opts[:class]
        value = opts[:value]
        # Text area that auto saves to url.
        "<textarea reactive-form-path='#{path}' class='#{css_classes}'>#{value}</textarea>"
      end
    end
  end
end