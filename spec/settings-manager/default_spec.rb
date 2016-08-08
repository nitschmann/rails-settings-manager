require "spec_helper"

describe SettingsManager::Default do
  before(:all) { @instance = Class.new { include SettingsManager::Default } }

  describe "#default_settings" do
    context "no file given" do
      specify { expect(@instance.default_settings).to be_kind_of(Hash) }
      specify { expect(@instance.default_settings.keys.length).to eql(0) }
    end

    context "file present" do
      before(:all) do
        @instance.default_settings_config(File.expand_path("../../config/default_settings.yml", __FILE__))
      end

      after(:all) { @instance.default_settings_config(nil) }

      specify { expect(@instance.default_settings).to be_kind_of(Hash) }
      specify { expect(@instance.default_settings.keys.length).to be > 0 }
      specify { expect(@instance.default_settings.keys).to include("page_title") }
    end
  end

  describe "#default_settings_config" do
    context "default" do
      specify do
        expect(@instance.instance_variable_get(:@default_settings_config_path)).
          to be_nil
      end
    end

    context "is set" do
      let(:file_path) {
        File.expand_path("../../config/default_settings.yml", __FILE__)
      }

      after(:all) { @instance.default_settings_config(nil) }

      specify do
        @instance.default_settings_config(file_path)

        expect(@instance.instance_variable_get(:@default_settings_config_path)).
          to eql(file_path)
      end
    end
  end

  describe "#default_setting_for" do
    context "no file present" do
      specify { expect(@instance.default_setting_for("foo")).to be_nil }
    end

    context "file present" do
      before(:all) do
        @instance.default_settings_config(File.expand_path("../../config/default_settings.yml", __FILE__))
      end

      after(:all) { @instance.default_settings_config(nil) }

      context "expected key is not listed in file" do
        specify { expect(@instance.default_setting_for("foo")).to be_nil }
      end

      context "expected key is listed in file" do
        specify do
          expect(@instance.default_setting_for("page_title")).
            to eql("My site")
        end
      end
    end
  end
end
