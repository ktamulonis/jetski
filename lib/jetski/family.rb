# lib/jetski/family.rb
module Jetski
  module Family
    extend self

    def reset!
      @parents = Hash.new { |h, k| h[k] = {} }
      @kids    = Hash.new { |h, k| h[k] = {} }
      @models  = []
    end

    def bootstrap!(models)
      reset!
      @models = models

      models.each do |child|
        child.attributes.each do |attr|
          next unless attr.end_with?("_id")

          parent_name  = attr.sub(/_id$/, "")
          parent_class = constantize(parent_name)
          next unless parent_class
          next unless parent_class < Jetski::Model

          @parents[child][parent_name.to_sym] = parent_class
          @kids[parent_class][pluralize(child)] = child
        end
      end

      # 🔑 generate instance-level parent methods
      models.each do |model|
        define_parent_methods!(model)
      end
    end

    def parents_for(model)
      @parents[model]
    end

    def kids_for(model)
      @kids[model]
    end

    def family_for(model)
      ([model] + parents_for(model).values + kids_for(model).values).uniq
    end

    def define_parent_methods!(model)
      parents_for(model).each do |assoc_name, parent_class|
        fk = "#{assoc_name}_id"

        model.class_eval do
          define_method assoc_name do
            parent_id =
              @virtual_attributes[fk.to_s] ||
              @virtual_attributes[fk.to_sym]

            return nil if parent_id.nil?

            parent_class.find(parent_id)
          end
        end
      end
    end

    private

    def constantize(name)
      Object.const_get(name.capitalize)
    rescue NameError
      nil
    end

    def pluralize(klass)
      n = klass.name.downcase
      (n.end_with?("s") ? n : "#{n}s").to_sym
    end
  end
end

