require_relative "stream"
require_relative "events"

module Jetski
  class Model
    extend Jetski::Database::Base

    def initialize(**args)
      @virtual_attributes = args
    end

    def inspect
      post_obj_id = object_id
      inspect_str = "#<#{self.class.to_s}:#{post_obj_id}"
      self.class.attributes.each do |attribute_name|
        attribute_value = @virtual_attributes[attribute_name]
        inspect_str += " #{attribute_name}=\"#{attribute_value}\""
      end
      inspect_str += ">"
      inspect_str
    end

    def destroy!
      # Destroy record: remove from db
      delete_sql = <<~SQL
        DELETE from #{self.class.pluralized_table_name} WHERE id=?
      SQL
      self.class.db.execute(delete_sql, id)
      nil
    end

    def patch(attrs)
      self.class.patch(id, attrs)
    end

    def append(field, value)
      self.class.append(id, field, value)
    end

    class << self
      def create(hash_args = nil, **key_args)
        args = if hash_args && hash_args.is_a?(Hash)
          hash_args
        else
          key_args
        end

        return puts "#{table_name.capitalize}.create was called with no args" if args.size == 0
        data_values = args.map { |k,v| v }
        key_names = args.map { |k, v| k }
        
        # Set default values on create

        key_names.append "created_at"
        data_values.append Time.now.to_s

        current_post_count = (count || 0)
        post_id = current_post_count + 1
        key_names.append "id"
        data_values.append(post_id)

        sql_command = <<~SQL
          INSERT INTO #{pluralized_table_name} (#{key_names.join(", ")}) 
          VALUES (#{(1..key_names.size).map { |n| "?" }.join(", ")})
        SQL

        db.execute(sql_command, data_values)

        post_attributes = {}
        key_names.each.with_index do |k, i|
          post_attributes[k] = data_values[i]
        end

        define_attribute_methods
        new(**post_attributes)
      end

      # Careful methods / delete all records from table
      def destroy_all! 
        db.execute("DELETE from #{pluralized_table_name}")
      end

      # TODO: Find a better solution than this
      def define_attribute_methods
        attributes.each do |attribute|
          define_method attribute do
            @virtual_attributes[attribute]
          end
        end
      end

      def all
        columns, *rows = db.execute2( "select * from #{pluralized_table_name}" )
        _all = []
        rows.map do |row|
          _all << format_model_obj(row, columns)
        end
        _all
      end

      def pluck_rows
        db.execute( "select * from #{pluralized_table_name}" )
      end

      def count
        pluck_rows.size
      end

      def attributes
        # TODO: Find a more performant way to get the column names from a table
        columns, *rows = db.execute2( "select * from #{pluralized_table_name}" )
        columns
      end

      def last
        format_model_obj(pluck_rows.last)
      end

      def first
        format_model_obj(pluck_rows.first)
      end

      def find(id)
        id_as_integer = id.to_i
        columns, *rows = db.execute2( "select * from #{pluralized_table_name} WHERE id=?", id_as_integer)
        format_model_obj(rows.last, columns)
      end
      
      # ---- CLASS-LEVEL MUTATION ----

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
        current = record.public_send(field)

        patch(id, field => current.to_s + value.to_s)
      end

      def table_name
        self.to_s.downcase
      end

      def pluralized_table_name
        if table_name[-1] == "s"
          table_name
        else
          table_name + "s"
        end
      end

    private

      def format_model_obj(row, columns = nil)
        return unless row
        columns ||= attributes
        row_obj = {}
        columns.each.with_index do |col, idx|
          row_obj[col] = row[idx]
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
