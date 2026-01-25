class Jetski
  module Helpers
    module Generic
      # Helpers for use all over codebase for simple grammatics etc..
      def pluralize_string(string)
        if string[-1] == 's'
          string
        else
          string + 's'
        end
      end
    end
  end
end