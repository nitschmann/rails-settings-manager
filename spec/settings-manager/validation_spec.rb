require "spec_helper"

describe SettingsManager::Validation do
  before(:all) do
    ValidateSetting = Class.new(Setting) do
      allowed_settings_keys [:comments_active, :site_name]

      validates_setting :comments_active,
        :inclusion => {
          :in => [false,true]
        }

      validates_setting :site_name,
        :length => {
          :maximum => 100,
          :minimum => 3
        }
    end
  end

  describe "#[]" do
    context "invalid key" do
      let(:key) { "invalid_key" }
      subject { ValidateSetting[key] }

      specify do
        expected_msg = "unallowed key `#{key}`"
        expect{ subject }.
          to raise_error(SettingsManager::Errors::KeyInvalidError, expected_msg)
      end
    end
  end

  describe "#[]=" do
    context "invalid key" do
      let(:key) { "invalid_key" }
      subject { ValidateSetting[key] = "value" }

      specify do
        expected_msg = "unallowed key `#{key}`"
        expect{ subject }.
          to raise_error(SettingsManager::Errors::KeyInvalidError, expected_msg)
      end
    end

    context "invalid value for valid key" do
      let(:key) { "site_name" }
      let(:value) { "a" }

      subject do
        begin
          ValidateSetting[key] = value
        rescue => e
          e
        end
      end

      it "returns an error" do
        expect(subject).
          to be_a(SettingsManager::Errors::InvalidError)
      end

      it "includes an error message" do
        expect(subject.errors.length).to eql(1)
      end
    end
  end
end
