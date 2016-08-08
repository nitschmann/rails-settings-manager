# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "settings-manager/version"

Gem::Specification.new do |spec|
  spec.name          = "rails-settings-manager"
  spec.version       = SettingsManager::VERSION
  spec.authors       = ["Florian Nitschmann"]
  spec.email         = ["f.nitschmann@googlemail.com"]
  spec.homepage      = "https://github.com/fnitschmann/rails-settings-manager"
  spec.license       = "MIT"

  spec.summary       = ""
  spec.description   = %q{TODO: Write a longer description or delete this line.}

  spec.files         = Dir.glob("lib/**/*") + ["README.md", "LICENSE.txt"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.1.0"

  spec.add_dependency "rails", "~> 4.2.0"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry-rails"
end
