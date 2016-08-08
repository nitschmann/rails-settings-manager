require "spec_helper"

describe SettingsManager::Base do
  before(:all) do
    DefaultSetting = Class.new(Setting)

    LimitedKeySetting = Class.new(Setting) do
      allowed_settings_keys [
        :page_title,
        :page_description
      ]
    end
  end

  after(:each) { Setting.all.each { |setting| setting.destroy } }

  describe "#[]" do
    context "no limitations" do
      context "setting not present" do
        specify { expect(DefaultSetting["foo"]).to be_nil }
      end

      context "setting is present" do
        let(:value) { "bar" }

        specify do
          DefaultSetting["foo"] = value
          expect(DefaultSetting["foo"]).to eql(value)
        end
      end
    end

    context "key limitations" do
      context "invalid key" do
        specify do
          expected_msg = "unallowed setting key `foo`"

          expect{ LimitedKeySetting["foo"] }.
            to raise_error(SettingsManager::Errors::KeyNotDefiniedError, expected_msg)
        end
      end

      context "valid key" do
        context "setting not present" do
          specify { expect(LimitedKeySetting["page_description"]).to be_nil }
        end

        context "setting not present in db, but in default file" do
          before(:all) do
            LimitedKeySetting.
              default_settings_config(File.expand_path("../../config/default_settings.yml", __FILE__))
          end

          after(:all) { LimitedKeySetting.default_settings_config(nil) }

          specify { expect(LimitedKeySetting["page_title"]).not_to be_nil }
          specify { expect(LimitedKeySetting["page_title"]).to eql("My site") }
        end

        context "setting is present" do
          let(:value) { "This is my cool settings page" }

          specify do
            LimitedKeySetting["page_description"] = value
            expect(LimitedKeySetting["page_description"]).to eql(value)
          end
        end
      end
    end
  end

  describe "#[]=" do
    context "default" do
      let(:value) { "bar" }

      it "creates a new record" do
        expect{ DefaultSetting["foo"] = value }
          .to change{ DefaultSetting.count }.by(1)
      end

      it "returns given value" do
        expect(DefaultSetting["foo"] = value).to eql(value)
      end
    end

    context "key limitations" do
      context "with invalid key" do
        specify do
          expect{ LimitedKeySetting["foo"] = "bar" }.
            to raise_error(SettingsManager::Errors::InvalidError)
        end
      end

      context "with valid key" do
        let(:value) { "My settings website" }

        it "creates a new record" do
          expect{ LimitedKeySetting["page_title"] = value }.
            to change{ LimitedKeySetting.count }.by(1)
        end

        it "returns given value" do
          expect(LimitedKeySetting["page_title"] = value).to eql(value)
        end
      end
    end
  end

  describe "#destroy!" do
    context "setting not present in database" do
      let(:key) { "key123" }

      specify do
        expected_msg = "setting for `#{key}` not found"

        expect{ DefaultSetting.destroy!(key) }.
          to raise_error(SettingsManager::Errors::SettingNotFoundError, expected_msg)
      end
    end

    context "setting is present" do
      before do
        @key = "a_simple_key"
        DefaultSetting[@key] = "value"
      end

      it "destroys record" do
        expect{ DefaultSetting.destroy!(@key) }.
          to change{ DefaultSetting.count }.by(-1)
      end
    end
  end
end
