require "json"
require "thread"

class Jetski
  class Stream
    @mutex = Mutex.new
    @writers = [] # array of Proc objects: ->(data) { out << data }
    @shutdown = false
    @shutdown_requested = false
    @shutdown_mutex = Mutex.new
    @shutdown_cv = ConditionVariable.new

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

      def shutdown!
        @shutdown_mutex.synchronize do
          @shutdown = true
          @shutdown_cv.broadcast
        end
      end

      def reset_shutdown!
        @shutdown_mutex.synchronize do
          @shutdown = false
        end
      end

      def signal_shutdown
        @shutdown_requested = true
      end

      def shutdown_signaled?
        @shutdown_requested
      end

      def shutdown?
        @shutdown_mutex.synchronize { @shutdown }
      end

      def wait_for_shutdown(timeout)
        @shutdown_mutex.synchronize do
          return true if @shutdown

          @shutdown_cv.wait(@shutdown_mutex, timeout)
          @shutdown
        end
      end
    end
  end
end
