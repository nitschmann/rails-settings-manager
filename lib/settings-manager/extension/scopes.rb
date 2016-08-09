module SettingsManager
  module Extension
    module Scopes
      extend ActiveSupport::Concern

      included do
        scope :with_settings, lambda {
          class_name = self.base_class.name
          settings_table = self.settings_base_class.to_s.constantize.table_name
          table = self.table_name

          joins("INNER JOIN #{settings_table} ON (
                  #{settings_table}.base_obj_id = #{table}.#{primary_key} AND
                  #{settings_table}.base_obj_type = '#{class_name}'
                )")
            .select("DISTINCT #{table}.*")

        }

        scope :with_settings_for, lambda { |var|
          class_name = self.base_class.name
          settings_table = self.settings_base_class.to_s.constantize.table_name
          table = self.table_name

          joins("INNER JOIN #{settings_table} ON (
                  #{settings_table}.base_obj_id = #{table}.#{primary_key} AND
                  #{settings_table}.base_obj_type = '#{class_name}' AND
                  #{settings_table}.key = '#{var.to_s}'
                )")
        }

        scope :without_settings, lambda {
          class_name = self.base_class.name
          settings_table = self.settings_base_class.to_s.constantize.table_name
          table = self.table_name

          joins("LEFT JOIN #{settings_table} ON (
                  #{settings_table}.base_obj_id = #{table}.#{primary_key} AND
                  #{settings_table}.base_obj_type = '#{class_name}'
                )")
            .where("#{settings_table}.id IS NULL")
        }

        scope :without_settings_for, lambda { |var|
          class_name = self.base_class.name
          settings_table = self.settings_base_class.to_s.constantize.table_name
          table = self.table_name

          where("#{settings_table}.id IS NULL")
            .joins("LEFT JOIN #{settings_table} ON (
                    #{settings_table}.base_obj_id = #{table}.#{primary_key} AND
                    #{settings_table}.base_obj_type = '#{class_name}' AND
                    #{settings_table}.key = '#{var.to_s}'
                  )")
        }
      end
    end
  end
end
