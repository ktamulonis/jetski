module JetskiCLIHelpers
  class Destroy < Base
    include JetskiCLIHelpers::Destroyers::Controller,
    JetskiCLIHelpers::Destroyers::Model
    desc "controller NAME ACTION_NAMES", "Destroys a controller"
    def controller(name, *actions)
      destroy_controller(name)
    end

    desc "model NAME ACTION_NAMES", "Destroys a model"
    def model(name, *actions)
      destroy_model(name)
    end

    desc "resource NAME ACTION_NAMES", "Destroys a resource"
    def resource(name, *actions)
      destroy_controller(name)
      destroy_model(name)
    end
  end
end