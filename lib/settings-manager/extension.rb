require "settings-manager/extension/scopes"

module SettingsManager
  module Extension
    extend ActiveSupport::Concern

    include Scopes

    def settings
      base_class = self.class.settings_base_class.to_s.constantize

      wrapped_class = base_class.clone
      wrapped_class.instance_variable_set(:@base_obj, self)

      wrapped_class.instance_eval do
        def base_query
          where(
            :base_obj_id => @base_obj.id,
            :base_obj_type => @base_obj.class.to_s
          )
        end

        def model_name
          @base_obj.class.settings_base_class.to_s.constantize.model_name
        end
      end

      wrapped_class
    end

    module ClassMethods
      def settings_base_class(class_name = nil)
        if class_name.present?
          @settings_base_class = class_name.to_s
        else
          @settings_base_class || "Setting"
        end
      end
    end
  end
end
