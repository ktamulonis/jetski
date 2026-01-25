class Jetski
  class Model
    module Attributes
      # class method for user to configure add/remove attributes on model
      def attributes(*string_attributes, **custom_attributes)
        @_db_string_attributes = string_attributes
        @_db_custom_attributes = custom_attributes
        combined_attributes = string_attributes + custom_attributes.map { |k, _v| k }
        @_attribute_names ||= []
        @_attribute_names.concat(combined_attributes)
        @_attribute_names.concat([:created_at, :updated_at, :id]) # defaults
        @_attribute_names = @_attribute_names.uniq
        @_attribute_names.each do |attribute|
          define_method attribute do
            @virtual_attributes[attribute]
          end
        end
      end

      def attribute_names
        @_attribute_names || []
      end

      def db_attribute_values
        # Returns the formatted objects with types for each attribute
        _db_attributes = []
        
        @_db_string_attributes.each do |value|
          _db_attributes << {
            name: value,
            type: :string
          }
        end

        @_db_custom_attributes.each do |key, value|
          _db_attributes << {
            name: key,
            type: value
          }
        end

        _db_attributes
      end
    end
  end
end