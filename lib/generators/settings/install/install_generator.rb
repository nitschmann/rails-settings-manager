require "rails/generators"
require "rails/generators/migration"

module Settings
  class InstallGenerator < Rails::Generators::NamedBase
    include Rails::Generators::Migration

    source_root File.expand_path("../templates", __FILE__)
    desc "Installs migration, model and default file for settings"

    argument :name, :type => :string, :default => "setting"

    def main
      @class_name = class_name
      @default_config_file = "default_" + table_name + ".yml"
      @migration_class_name = "Create" + table_name.camelize
      @table_name = table_name

      copy_migration
      copy_model
      copy_default_config
    end

    def self.next_migration_number(dirname)
      if ActiveRecord::Base.timestamped_migrations
        if Dir.glob(dirname + "/*.rb").any?
          current_migration_number(dirname) + 1
        else
          Time.now.utc.strftime("%Y%m%d%H%M%S")
        end
      else
        format("%.3d", current_migration_number(dirname) + 1)
      end
    end

    private

    def copy_default_config
      template("default.yml", "config/#{@default_config_file}")
    end

    def copy_migration
      migration_file = @migration_class_name.underscore + ".rb"
      migration_template("migration.rb.erb", "db/migrate/#{migration_file}")
    end

    def copy_model
      template("model.rb.erb", File.join("app/models", "#{file_path}.rb"))
    end
  end
end
