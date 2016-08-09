require "spec_helper"

describe SettingsManager::Extension do
  after(:each) { User.all.each { |user| user.destroy } }
  after(:each) { Setting.all.each { |setting| setting.destroy } }

  describe "#settings_base_class" do
    specify { expect(User).to respond_to(:settings_base_class) }

    context "default" do
      specify { expect(User.settings_base_class).to eql("Setting") }
    end

    context "another settings class" do
      before do
        AnotherSetting = Class.new(Setting)
        SpecialUser = Class.new(User) { settings_base_class AnotherSetting }
      end

      specify { expect(SpecialUser.settings_base_class).to eql(AnotherSetting.to_s) }
    end
  end

  describe ".settings" do
    describe ".class" do
      let(:user) { User.create(:username => "tester") }

      specify { expect(user.settings.class).to eql(Class) }
    end

    describe ".base_obj" do
      let(:user) { User.create(:username => "tester") }

      subject { user.settings.instance_variable_get(:@base_obj) }
      specify { expect(subject).to eql(user) }
    end

    describe ".base_query" do
      let(:user) { User.create(:username => "tester") }
      let(:query) { user.settings.base_query.to_sql.to_s }

      specify { expect(query).to include(".\"base_obj_id\" = #{user.id}") }
      specify do
        expect(query).to include(".\"base_obj_type\" = '#{user.class.to_s}'")
      end
    end

    describe ".model_name" do
      let(:user) { User.create(:username => "tester") }

      specify do
        expect(user.settings.model_name).
          to equal(AnotherSetting.superclass.model_name)
      end
    end

    describe ".table_name" do
      let(:user) { User.create(:username => "tester") }

      specify { expect(user.settings.table_name).to eql(Setting.table_name) }
    end

    context "without limitations" do
      before(:all) do
        UserSetting = Class.new(Setting)
        NoLimitUser = Class.new(User) { settings_base_class UserSetting }
      end

      describe "#[]" do
        context "default" do
          let(:user) { NoLimitUser.create(:username => "tester") }

          specify { expect(user.settings.foo).to be_nil }
        end

        context "value for key is set" do
          let(:user) { NoLimitUser.create(:username => "tester") }
          let(:twitter_user) { "CoolTwitterUser" }

          specify do
            user.settings.twitter_user = twitter_user
            expect(user.settings.twitter_user).to eql(twitter_user)
          end
        end
      end

      describe "#[]=" do
        let(:twitter_username) { "twitter-user" }

        context "default" do
          let(:user) { NoLimitUser.create(:username => "tester") }

          subject { user.settings["twitter"] = twitter_username }

          specify { expect{ subject }.to change{ UserSetting.count }.by(1) }
          specify { expect(subject).to eql(twitter_username) }
        end

        context "setting already set" do
          let(:user) { NoLimitUser.create(:username => "tester") }

          before { user.settings["twitter"] = twitter_username }
          subject { user.settings["twitter"] = twitter_username }

          specify { expect{ subject }.not_to change{ UserSetting.count } }
          specify { expect(subject).to eql(twitter_username) }
        end
      end

      describe "#get_all" do
        let(:user) { NoLimitUser.create(:username => "tester") }

        context "default" do
          specify { expect(user.settings.get_all).to be_kind_of(Hash) }
          specify { expect(user.settings.get_all).to be_empty }
        end

        context "settings present" do
          let(:settings) { { "key" => "value"} }

          before { user.settings.set(settings) }

          specify { expect(user.settings.get_all).to be_kind_of(Hash) }
          specify { expect(user.settings.get_all).not_to be_empty }
          specify { expect(user.settings.get_all.length).to eql(settings.length) }
        end
      end
    end

    context "with limitations" do
      before(:all) do
        LimitedUserSetting = Class.new(Setting) do
          allowed_settings_keys [:twitter_handle]
        end

        LimitedUser = Class.new(User) { settings_base_class LimitedUserSetting }
      end

      describe "#[]" do
        let(:user) { LimitedUser.create(:username => "tester") }

        context "invalid key" do
          let(:key) { "github_username" }

          specify do
            expected_msg = "unallowed setting key `#{key}`"

            expect{ user.settings[key] }.
              to raise_error(SettingsManager::Errors::KeyNotDefiniedError, expected_msg)
          end
        end

        context "valid key" do
          context "default" do
            specify { expect(user.settings.twitter_handle).to be_nil }
          end

          context "not in database present, but in default config" do
            before do
              LimitedUserSetting.
                default_settings_config(File.expand_path("../../config/default_settings.yml", __FILE__))
            end

            after { LimitedUserSetting.default_settings_config(nil) }

            it "returns the predefined default value" do
              expect(user.settings["twitter_handle"]).to eql("twitter-user")
            end
          end

          context "present in database" do
            let(:value) { "ACoolTwitterUser" }

            before { user.settings["twitter_handle"] = value }

            it "returns value from database" do
              expect(user.settings["twitter_handle"]).to eql(value)
            end
          end
        end
      end
    end
  end
end

