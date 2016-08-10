module SettingsManager
  module Errors
    class BaseError < StandardError ; end
    class SettingNotFoundError < BaseError ; end

    class InvalidError < BaseError
      class ComplexErrorArray < Array
        def <<(obj)
          unless obj.is_a?(String) || obj.is_a?(ActiveModel::Errors)
            raise ArgumentError
          end

          super
        end

        def messages
          messages = []

          self.each do |message|
            if message.is_a?(String)
              messages << message
            elsif message.is_a?(ActiveModel::Errors)
              message.full_messages.each { |m| messages << m }
            end
          end

          messages.uniq
        end
      end

      attr_reader :errors

      def initialize
        @errors = ComplexErrorArray.new
      end
    end

    class KeyInvalidError < BaseError
      attr_reader :key

      def initialize(key = nil)
        @key = key || ""
      end

      def message
        "unallowed key `#{@key}`"
      end
    end
  end
end
