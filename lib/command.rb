module Command
  module Executable
    def self.included(base)
      base.include ActiveModel::Model
      base.include ActiveModel::Attributes
    end

    def call
      raise NotImplementedError, "#{self.class} must implement #call"
    end

    private

    def event_store
      Rails.configuration.event_store
    end

    def command_bus
      Rails.configuration.command_bus
    end
  end

  module Handler
    def self.included(base)
      base.extend ClassMethods
      base.instance_variable_set(:@_command_handlers, {})
    end

    module ClassMethods
      def handles(command_class, method_name)
        @_command_handlers ||= {}
        @_command_handlers[command_class] = method_name
      end

      def command_handlers
        @_command_handlers || {}
      end

      def register_commands(command_bus)
        instance = new
        command_handlers.each do |command_class, method_name|
          command_bus.register(command_class, ->(cmd) { instance.public_send(method_name, cmd) })
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
