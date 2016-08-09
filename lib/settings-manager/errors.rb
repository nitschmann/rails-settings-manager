module SettingsManager
  module Errors
    class BaseError < StandardError ; end
    class KeyInvalidError < BaseError ; end
    class InvalidError < BaseError ; end
    class SettingNotFoundError < BaseError ; end
  end
end
