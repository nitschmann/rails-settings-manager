require "settings-manager/default"
require "settings-manager/errors"
require "settings-manager/validation"

module SettingsManager
  class Base < ActiveRecord::Base
    include SettingsManager::Default
    include SettingsManager::Validation

    self.abstract_class = true

    def value
      YAML.load(self[:value]) if self[:value].present?
    end

    def value=(new_value)
      self[:value] = new_value.to_yaml
    end

    class << self
      def [](key)
        if key_allowed?(key)
          object = object(key)

          if object.present?
            object.value
          else
            default_setting_for(key)
          end
        else
          raise Errors::KeyNotDefiniedError, "unallowed setting key `#{key}`"
        end
      end

      def []=(key, value)
        key = key.to_s
        attributes = { :key => key }

        if @base_obj
          attributes[:base_obj_id] = @base_obj.id
          attributes[:base_obj_type] = @base_obj.class.to_s
        end

        record = object(key) || self.new(attributes)
        record.value = value
        record.save!

        value
      rescue ActiveRecord::RecordInvalid => e
        e.record.errors.full_messages.each do |msg|
          self.add_error(msg)
        end

        raise Errors::InvalidError
      end

      def destroy!(key)
        record = object(key.to_s)

        if record.present?
          record.destroy!
        else
          raise Errors::SettingNotFoundError, "setting for `#{key.to_s}` not found"
        end
      end

      def get_all
        result = default_settings

        base_query.each do |record|
          result[record.key] = record.value
        end

        result
      end

      def method_missing(method, *args)
        method_name = method.to_s
        super(method, *args)
      rescue NoMethodError => e
        if method_name[-1] == "="
          key = method_name.sub("=", "")
          value = args.first

          self[key] = value
        else
          self[method_name]
        end
      end

      def object(key)
        return nil unless Rails.application.initialized? && table_exists?

        base_query.find_by(:key => key.to_s)
      end

      def set(settings = {})
        ActiveRecord::Base.transaction do
          settings.each do |key, value|
            self[key.to_s] = value
          end
        end

        self.get_all
      end

      def base_query
        where(:base_obj_id => nil, :base_obj_type => nil)
      end
    end
  end
end
