# frozen_string_literal: true

module PagesCore
  module PubSub
    class << self
      def publish(name, payload = {})
        payload_struct = OpenStruct.new(payload)
        subscribers.select { |s| s.name == name }
                   .each { |s| s.call(payload_struct) }
      end

      def subscribe(name, &block)
        subscriber = PagesCore::PubSub::Subscriber.new(name, block)
        subscribers << subscriber
        subscriber
      end

      def subscribers
        @subscribers ||= []
      end

      def unsubscribe(subscriber)
        @subscribers = subscribers.reject { |s| s == subscriber }
      end
    end

    class Subscriber
      attr_reader :name, :callback

      delegate :call, to: :callback

      def initialize(name, callback)
        @name = name
        @callback = callback
      end
    end
  end
end
