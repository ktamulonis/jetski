class Jetski
  module Helpers
    module Delegatable
      # delegate(:method, to: :class)
      # Allows you to delegate a method to another class
      def delegate(*delegatables, to:)
        delegatables.each do |method_name|
          define_method method_name do
            public_send(to).public_send(method_name)
          end
        end
      end
    end
  end
end