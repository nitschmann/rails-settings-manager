module SettingsManager
  module Validation
    extend ActiveSupport::Concern

    included do
      after_commit :reset_class_errors

      validates_inclusion_of :key,
        in: ->(r) { r.class.allowed_settings_keys.map { |k| k.to_s } },
        if: Proc.new { |r| r.class.allowed_settings_keys.any? }

      validates_uniqueness_of :base_obj_id,
        :scope => [:key, :base_obj_type]
    end

    def allowed_settings_keys
      self.class.allowed_settings_keys
    end

    def reset_class_errors
      self.class.reset_errors
    end

    module ClassMethods
      attr_reader :errors

      def add_error(message)
        @errors = [] if @errors.nil?
        @errors << message
      end

      def allowed_settings_keys(keys = nil)
        if keys.present? && keys.kind_of?(Array)
          @allowed_settings_keys = keys
        else
          @allowed_settings_keys || []
        end
      end

      def errors
        @errors || []
      end

      def key_allowed?(key)
        if allowed_settings_keys.any?
          allowed_settings_keys.include?(key.to_sym)
        else
          true
        end
      end

      def reset_errors
        @errors = []
      end

      def validates_setting(value, options = {})
        options[:if] = Proc.new { |record| value.to_s == record.key.to_s }
        validates(:value, options)
      end
    end
  end
end
