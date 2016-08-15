# rails-settings-manager

A simple extension-plugin for Ruby on Rails application for global settings management in the Database with an easy key-value interface. It keeps track of the settings with the help of standard ActiveRecord methods.

## Features

* Simple management of a global settings table (or even multiple if wanted) in Ruby on Rails applications with an easy key-value interface
* Behaves like a global Hash stored in the database of the app with full-usage of standard ActiveRecord methods for manipulation, queries and validation
* Support for key limitations and setting-value validations in the setting models
* Support for any kind of Object (e.g. ` integer `, ` float `, ` string ` or ` array `)
* Also modular application structures (e.g. ` Rails::Engine `) are supported

## Requirements

* Ruby (Version ` >= 2.1.0 `)
* Rails (Version ` >= 4.2.0 `) [Note: ` Rails V 5.0.0 ` and above should also work fine, but are not tested yet completly. If any failures might happen with it feel free to report an [Issue](https://github.com/fnitschmann/rails-settings-manager/issues)] 

## Installation

Add this line to your application's Gemfile:

```ruby
gem "rails-settings-manager"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rails-settings-manager
    

Generate the required settings files:

    $ rails g settings:install
    
If wanted with a custom model name:

    $ rails g settings:install CustomName

Then run your migrations:

    $ bundle exec rake db:migrate

## Usage

### Basic syntax

The setting syntax is easy. Create some basic settings if wanted:

```ruby
Setting.admin_username = "admin"
Setting.admin_password = "superadminpassword"
Setting.some_numbers = 123
Setting.other_credentials = { :username => "user", :password => "userpassword" } 
Setting["array_like_setting"] = []
```

Read them:

```ruby
Setting.some_numbers            # returns 123
Setting["some_numbers"]         # returns 123
```

Change already existing setting:

```ruby
Setting.some_numbers = 321      # returns 321
```

Set multiple at once:

```ruby
Setting.set(:foo => "bar", :bar => "baz") 
```

Destroy a single setting and read it again:

```ruby
Setting.destroy!(:some_numbers) # will raise SettingsManager::Errors::SettingNotFoundError 
                                # if key not set yet
Setting.some_numbers            # returns nil or (if set) the default value
```

Get all settings at once:

```ruby
Setting.get_all                 # returns Hash
```

### Defaults

The Gem supports ` .yml ` files which can hold default settings.

To set the default to a settings model add the following lines:

```ruby
class Setting < SettingsManager::Base
    default_settings_config Rails.root.join("config/default_settings.yml")
end
```

The specified file should look like:

```yaml
defaults: &defaults
  some_key: "some_value"

development:
  <<: *defaults

test:
  <<: *defaults

production:
  <<: *defaults
```

Test it:

```ruby
Setting.some_key        # returns "some_value" if nothing in the Database is present
```

### Key limitations

There is also an option to restrict to usage of certain keys.

```ruby
class Setting < SettingsManager::Base
    allowed_settings_keys [:admin_username, :admin_password]
    ...
end
```

Test it:

```ruby
Setting.foo                     # will raise SettingsManager::Errors::KeyInvalidError
Setting.foo = "bar"             # will raise SettingsManager::Errors::KeyInvalidError
Setting.admin_username = "xxx"  # returns "xxx"
```
Note: Check the [Errors Module](https://github.com/fnitschmann/rails-settings-manager/blob/master/lib/settings-manager/base.rb) for more details about the exceptions

### Validation

Validations of the setting values for certain keys are also possible. You can use all the [ActiveRecord Validations](http://guides.rubyonrails.org/active_record_validations.html). The only exception currently is, that you can't use an ` if ` block statement in the validation ` options `.

Example:

```ruby
class Setting < SettingsManager::Base
    validates_setting :setting_to_validate,
        :length => { :minimum => 5, :maximum => 100 }
    ...
end
```

Test it out:

```ruby
Setting.setting_to_validate = "123"     # will raise SettingsManager::Errors::InvalidError
```
Note: Check the [Errors Module](https://github.com/fnitschmann/rails-settings-manager/blob/master/lib/settings-manager/base.rb) for more details about the exceptions

### Extension for models

Settings can be bound on any already-existing ActiveRecord object (aka model). 
Define this association like this:

```ruby
class User < ActiveRecord::Base
    include SettingsManager::Extension
    
    # Note: the following line is optional if the name of your settings model is 'Setting'
    # if not so it is obligatory (String or Class)
    settings_base_class Setting
end
```

Usage:

```ruby
user = User.find(1)
user.settings.foo = "bar"
user.settings.foo           # returns "bar"
user.settings.get_all       # returns { "foo" => "bar" }
```

Scopes:

```ruby
User.with_settings
# => returns all users with any settings

User.with_settings_for(:key)
# => returns all users with settings for 'key'

User.without_settings
# => returns all users without any settings

User.without_settings_for(:key)
# => returns all users without settings for 'key'
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `bundle exec rake rspec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fnitschmann/rails-settings-manager


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
