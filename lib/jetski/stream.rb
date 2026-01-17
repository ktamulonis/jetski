require "json"
require "thread"

module Jetski
  class Stream
    @mutex = Mutex.new
    @writers = [] # array of Proc objects: ->(data) { out << data }

    class << self
      def subscribe(&writer)
        return unless writer

        @mutex.synchronize do
          @writers << writer
        end
      end

      def unsubscribe(writer)
        @mutex.synchronize do
          @writers.delete(writer)
        end
      end

      def broadcast(payload)
        data = "data: #{JSON.dump(payload)}\n\n"

        writers = @mutex.synchronize { @writers.dup }

        writers.each do |writer|
          begin
            writer.call(data.to_s)
          rescue
            unsubscribe(writer)
          end
        end
      end

    end
  end
end

