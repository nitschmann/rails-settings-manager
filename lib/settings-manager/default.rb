module SettingsManager
  module Default
    extend ActiveSupport::Concern

    module ClassMethods
      def default_settings
        file = @default_settings_config_path

        if file && ::File.exist?(file)
          YAML.load_file(file)[Rails.env] || {}
        else
          {}
        end
      end

      def default_settings_config(path = nil)
        @default_settings_config_path = path
      end

      def default_setting_for(key)
        default_settings[key.to_s]
      end
    end
  end
end
