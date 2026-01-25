require_relative "stream"
require_relative "events"

class Jetski
  class Model
    extend Jetski::Database::Base, Jetski::Helpers::Generic,
      Jetski::Model::Attributes
    include CrudHelpers, Jetski::Helpers::Generic

    def initialize(**args)
      @virtual_attributes = args
      self.class.define_attribute_methods(@virtual_attributes.keys)
    end

    def inspect
      inspect_str = "#<#{self.class.to_s}:#{object_id}"
      self.class.attribute_names.each do |attribute_name|
        attribute_value = @virtual_attributes[attribute_name]
        inspect_str += " #{attribute_name}=\"#{attribute_value}\""
      end
      inspect_str += ">"
      inspect_str
    end

    def patch(attrs)
      self.class.patch(id, attrs)
    end

    def append(field, value)
      self.class.append(id, field, value)
    end

    class << self
      extend Jetski::Helpers::Delegatable
      delegate :count, :last, :first, to: :all

      def table_name
        self.to_s.downcase
      end

      def pluralized_table_name
        pluralize_string(table_name)
      end

      def define_attribute_methods(attributes = nil)
        attributes ||= column_names
        attributes.map!(&:to_sym)

        attributes.each do |attribute|
          next if instance_methods.include?(attribute)

          define_method attribute do
            @virtual_attributes[attribute]
          end
        end
      end

      def column_names
        columns, = db.execute2("select * from #{pluralized_table_name}")
        columns || []
      end

      def patch(id, attrs)
        record = find(id)
        return unless record

        update_row(id, attrs)

        Jetski::Events.publish(
          :model_patched,
          {
            model: name,
            id: id,
            changes: attrs,
            record: find(id)
          }
        )

        Jetski::Stream.broadcast(
          model: name,
          id: id,
          changes: attrs
        )

        find(id)
      end

      def append(id, field, value)
        record = find(id)
        return unless record

        current = record.public_send(field).to_s
        delta = value.to_s
        updated = current + delta

        update_row(id, field => updated)

        Jetski::Stream.broadcast(
          type: "model_append",
          model: name,
          id: id,
          attribute: field,
          delta: delta
        )

        Jetski::Events.publish(
          :model_appended,
          {
            model: name,
            id: id,
            attribute: field,
            delta: delta
          }
        )

        find(id)
      end

      # Mark attributes method as private hide it from IRB
      private :attributes
    private
      def format_model_obj(row, columns = nil)
        return unless row

        columns ||= column_names
        row_obj = {}
        columns.each.with_index do |col, idx|
          row_obj[col.to_sym] = row[idx]
        end
        new(**row_obj)
      end

      def update_row(id, attrs)
        set_clause = attrs.keys.map { |k| "#{k} = ?" }.join(", ")
        values = attrs.values

        sql = <<~SQL
          UPDATE #{pluralized_table_name}
          SET #{set_clause}
          WHERE id = ?
        SQL

        db.execute(sql, values + [id])
      end
    end
  end
end
