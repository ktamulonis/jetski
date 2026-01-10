module Jetski
  module Relations
    extend self

    def generate!
      graph = Jetski.kinship
      return unless graph

      graph.models.each do |model|
        define_has_many(model, graph)
        define_belongs_to(model, graph)
      end
    end

    private

    # Chat -> messages
    def define_has_many(model, graph)
      graph.children(model).each do |name, child_class|
        model.class_eval do
          define_method(name) do
            child_class.all.select do |child|
              child.public_send(:"#{model.name.downcase}_id") == id
            end
          end
        end
      end
    end

    # Message -> chat
    def define_belongs_to(model, graph)
      graph.parents(model).each do |name, parent_class|
        model.class_eval do
          define_method(name) do
            parent_id = public_send(:"#{name}_id")
            return nil unless parent_id

            parent_class.all.find { |record| record.id == parent_id }
          end
        end
      end
    end
  end
end

