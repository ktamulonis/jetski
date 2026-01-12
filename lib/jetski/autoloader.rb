module Jetski
  module Autoloader
    include Jetski::Router::FilePathHelper
    extend self

    # Responsibility is to load all models in app.
    def call
      loaded_models = []

      model_file_paths.each do |path_to_model|
        require_relative path_to_model

        model_name = path_to_model
          .split("app/models/")[-1]
          .gsub(".rb", "")
          .split("/")
          .map(&:capitalize)
          .join("::")

        model_class = Object.const_get(model_name)
        model_class.define_attribute_methods

        loaded_models << model_class
      end

      Jetski.kinship = Kinship.build(
        models: loaded_models,
        attribute_provider: ->(model) { model.attributes }
      )

      Jetski::Relations.generate!
    end

    def load_controllers
      controller_file_paths.each do |file_path|
        require_relative file_path
      end
    end
  end
end

