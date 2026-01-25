module JetskiCLIHelpers
  module Generators
    module Model
      def generate_model(name, *field_names)
        @model_name = name
        
        if field_names
          @model_attributes = []
          custom_fields = field_names.filter { |f| f.include?(":") }
          string_fields = field_names - custom_fields
          string_fields.each do |field|
            @model_attributes << ":#{field}"
          end

          custom_fields.each do |custom_field|
            field, type = custom_field.split(":")
            @model_attributes << "#{field}: :#{type}"
          end
        end
          
        model_file_path = "app/models/#{name}.rb"
        template "model/template.rb.erb", model_file_path
      end
    end
  end
end

