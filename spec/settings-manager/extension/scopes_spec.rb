require "spec_helper"

describe SettingsManager::Extension::Scopes do
  before(:all) do
    Setting.all
    ScopeUser = Class.new(User) { settings_base_class Setting }
  end

  after(:each) do
    ScopeUser.all.each { |user| user.destroy }
    Setting.all.each { |setting| setting.destroy }
  end

  describe "#with_settings" do
    let(:user1) { ScopeUser.create(:username => "user1") }
    let(:user2) { ScopeUser.create(:username => "user2") }
    let(:user3) { ScopeUser.create(:username => "user3") }

    before do
      user1.settings.setting_1 = "1"
      user2.settings.setting_2 = "2"
    end

    subject { ScopeUser.with_settings }

    specify { expect(subject).to include(user1) }
    specify { expect(subject).to include(user2) }
    specify { expect(subject).not_to include(user3) }
  end

  describe "#with_settings_for" do
    let(:user1) { ScopeUser.create(:username => "user1") }
    let(:user2) { ScopeUser.create(:username => "user2") }
    let(:user3) { ScopeUser.create(:username => "user3") }
    let(:key) { "a_specific_key" }

    before { user1.settings[key] = "a specific value" }
    subject { ScopeUser.with_settings_for(key) }

    specify { expect(subject).to include(user1) }
    specify { expect(subject).not_to include(user2) }
    specify { expect(subject).not_to include(user3) }
  end

  describe "#without_settings" do
    let(:user1) { ScopeUser.create(:username => "user1") }
    let(:user2) { ScopeUser.create(:username => "user2") }
    let(:user3) { ScopeUser.create(:username => "user3") }

    before do
      user1.settings.setting_1 = "1"
      user2.settings.setting_2 = "2"
    end

    subject { ScopeUser.without_settings }

    specify { expect(subject).not_to include(user1) }
    specify { expect(subject).not_to include(user2) }
    specify { expect(subject).to include(user3) }
  end

  describe "#without_settings_for" do
    let(:user1) { ScopeUser.create(:username => "user1") }
    let(:user2) { ScopeUser.create(:username => "user2") }
    let(:user3) { ScopeUser.create(:username => "user3") }
    let(:key) { "a_specific_key" }

    before { user1.settings[key] = "a specific value" }
    subject { ScopeUser.without_settings_for(key) }

    specify { expect(subject).not_to include(user1) }
    specify { expect(subject).to include(user2) }
    specify { expect(subject).to include(user3) }
  end
end
