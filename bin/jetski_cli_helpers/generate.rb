module JetskiCLIHelpers
  class Generate < Base
    include JetskiCLIHelpers::Generators::Controller,
      JetskiCLIHelpers::Generators::Model
    desc "controller NAME ACTION_NAMES", "Create a controller with matching actions"
    def controller(name, *actions)
      generate_controller(name, *actions)
    end

    desc "model NAME FIELD_NAMES", "Creates a model with matching fields"
    def model(name, *field_names)
      generate_model(name, *field_names)
    end

    desc "resource NAME FIELD_NAMES", "Creates a resource with model and controller and crud routes"
    def resource(name, *field_names)
      crud_actions = %w(new create show index edit update destroy)
      generate_model(name, *field_names)
      generate_controller(name, *crud_actions, field_names: field_names)
    end
  end
end