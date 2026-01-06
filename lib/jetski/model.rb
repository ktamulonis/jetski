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

    def method_missing(name, *args)
      # child collection (e.g. chat.messages)
      kids = self.class.kids
      if kids.key?(name)
        child_class = kids[name]
        fk = "#{self.class.name.downcase}_id"

        rows = child_class.db.execute(
          "SELECT * FROM #{child_class.pluralized_table_name} WHERE #{fk} = ?",
          id
        )

        columns = child_class.attributes
        return rows.map { |row| child_class.send(:new_from_row, row, columns) }
      end

      super
    end

    def respond_to_missing?(name, include_private = false)
      self.class.kids.key?(name) || super
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

        new(**post_attributes)
      end

      # Careful methods / delete all records from table
      def destroy_all! 
        db.execute("DELETE from #{pluralized_table_name}")
      end

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

      def parents
        Jetski::Family.parents_for(self)
      end

      def kids
        Jetski::Family.kids_for(self)
      end

      def family
        Jetski::Family.family_for(self)
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
      
      def new_from_row(row, columns)
        attrs = {}
        columns.each_with_index { |c, i| attrs[c] = row[i] }
        new(**attrs)
      end
      private :new_from_row

    end
  end
end
