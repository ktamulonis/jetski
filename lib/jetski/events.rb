# lib/jetski/events.rb
module Jetski
  module Events
    @subscribers = Hash.new { |h, k| h[k] = [] }

    class << self
      def subscribe(event, &block)
        @subscribers[event] << block
      end

      def publish(event, payload)
        @subscribers[event].each do |subscriber|
          subscriber.call(payload)
        end
      end

      # test helper
      def reset!
        @subscribers.clear
      end
    end
  end
end

