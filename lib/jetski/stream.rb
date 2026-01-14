# lib/jetski/stream.rb
module Jetski
  module Stream
    def self.broadcast(event, payload = {})
      Jetski::Events.publish(event, payload)
    end
  end
end

