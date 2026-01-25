class Jetski
  class Model
    module CrudHelpers
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      def destroy!
        # Destroy record: remove from db
        delete_sql = <<~SQL
          DELETE from #{self.class.pluralized_table_name} WHERE id=?
        SQL
        self.class.db.execute(delete_sql, id)
        nil
      end

      module ClassMethods
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

          current_record_count = (count || 0)
          record_id = current_record_count + 1
          key_names.append "id"
          data_values.append(record_id)

          sql_command = <<~SQL
            INSERT INTO #{pluralized_table_name} (#{key_names.join(", ")}) 
            VALUES (#{(1..key_names.size).map { |n| "?" }.join(", ")})
          SQL

          db.execute(sql_command, data_values)

          record_attributes = {}
          key_names.each.with_index do |k, i|
            record_attributes[k.to_sym] = data_values[i]
          end

          new(**record_attributes)
        end

        def all
          columns, *rows = db.execute2( "select * from #{pluralized_table_name}" )
          _all = []
          rows.map do |row|
            _all << format_model_obj(row, columns)
          end
          _all
        end

        def find(id)
          id_as_integer = id.to_i
          columns, *rows = db.execute2( "select * from #{pluralized_table_name} WHERE id=?", id_as_integer)
          format_model_obj(rows.last, columns)
        end
      

        def destroy_all! 
          db.execute("DELETE from #{pluralized_table_name}")
        end
      end
    end
  end
end