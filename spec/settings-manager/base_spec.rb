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
        let(:key) { "foo" }

        specify do
          expected_msg = "unallowed key `#{key}`"

          expect{ LimitedKeySetting[key] }.
            to raise_error(SettingsManager::Errors::KeyInvalidError, expected_msg)
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
        let(:key) { "foo" }

        specify do
          expected_msg = "unallowed key `#{key}`"

          expect{ LimitedKeySetting[key] = "bar" }.
            to raise_error(SettingsManager::Errors::KeyInvalidError, expected_msg)
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

  describe "#get_all" do
    context "default" do
      specify { expect(DefaultSetting.get_all).to be_kind_of(Hash) }
      specify { expect(DefaultSetting.get_all.keys.length).to eql(0) }
    end

    context "with default config file" do
      before(:all) do
        DefaultSetting.
          default_settings_config(File.expand_path("../../config/default_settings.yml", __FILE__))
      end

      after(:all) { DefaultSetting.default_settings_config(nil) }

      specify { expect(DefaultSetting.get_all).to be_kind_of(Hash) }
      specify { expect(DefaultSetting.get_all.keys.length).to be >= 1 }
    end

    context "with present records" do
      before { DefaultSetting["foo"] = "bar" }

      specify { expect(DefaultSetting.get_all).to be_kind_of(Hash) }
      specify { expect(DefaultSetting.get_all.keys.length).to be >= 1 }
      specify { expect(DefaultSetting.get_all.keys).to include("foo") }
    end
  end

  describe "#object" do
    context "default" do
      specify { expect(DefaultSetting.object("unprsent_key")).to be_nil }
    end
  end

  describe "#set" do
    context "no limitations" do
      let(:settings) { {"foo" => "bar", "batz" => "barz"} }

      subject { DefaultSetting.set(settings) }
      specify { expect(subject).to eql(settings) }
    end

    context "key limitations" do
      context "key is invalid" do
        subject do
          begin
            LimitedKeySetting.set(:foo => "bar")
          rescue => e
            e
          end
        end

        specify do
          expect(subject).to be_instance_of(SettingsManager::Errors::InvalidError)
        end

        specify { expect(subject.errors).not_to be_empty }
      end

      context "key is valid" do
        let(:key) { "page_title" }
        let(:value) { "A cool page" }

        it "creates new record" do
          expect{ LimitedKeySetting.set("#{key}" => "#{value}") }.
            to change{ LimitedKeySetting.count }.by(1)
        end

        it "includes value in result" do
          expect(LimitedKeySetting.set("#{key}" => "#{value}")[key]).
            to eql(value)
        end
      end
    end
  end
end
