module Handler
  # Returns a module for synchronous event handling.
  # queue param is accepted for API compatibility with async handlers.
  def self.async(queue: "default")
    Sync
  end

  module Sync
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def subscribes_to(*event_classes)
        @_subscribes_to = event_classes.flatten
      end

      def subscriptions
        @_subscribes_to || []
      end

      def build_subscriptions
        subscriptions.each_with_object({}) do |event_class, hash|
          hash[event_class] ||= []
          hash[event_class] << self
        end
      end
    end

    private

    def event_store
      Rails.configuration.event_store
    end

    def command_bus
      Rails.configuration.command_bus
    end
  end
end
