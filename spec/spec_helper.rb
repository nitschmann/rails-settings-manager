$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

require "rspec"
require "rails/all"
require "sqlite3"
require "pry"

require "settings-manager"

if SettingsManager::Base.respond_to?(:raise_in_transactional_callbacks=)
  SettingsManager::Base.raise_in_transactional_callbacks = false
end

class TestApplication < Rails::Application ; end

module Rails
  class << self
    def cache
      @cache ||= ActiveSupport::Cache::MemoryStore.new
    end

    def env
      "test"
    end

    def root
      Pathname.new(File.expand_path("../", __FILE__))
    end
  end
end

# SQLite3 in memory
ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "memory"
)

# migrations
ActiveRecord::Schema.verbose = false
ActiveRecord::Schema.define(:version => 1) do
  # settings table
  if ActiveRecord::Base.connection.table_exists?(:settings)
    drop_table :settings
  end

  create_table :settings do |t|
    t.string  :key,           :null => false
    t.text    :value,         :null => true
    t.integer :base_obj_id,   :null => true
    t.string  :base_obj_type, :null => true

    t.timestamps :null => false
  end

  # users table
  if ActiveRecord::Base.connection.table_exists?(:users)
    drop_table :users
  end

  create_table :users do |t|
    t.string :username, :null => false
  end
end

RSpec.configure do |config|
  config.before(:all) do
    class Setting < SettingsManager::Base ; end

    class User < ActiveRecord::Base
      include SettingsManager::Extension
    end
  end

  config.after(:all) { Object.send(:remove_const, :Setting) }
end

Rails.application.instance_variable_set("@initialized", true)
