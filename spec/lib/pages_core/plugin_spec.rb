require "rails_helper"

class TestPlugin < PagesCore::Plugin
  admin_menu_item "Test", "foo"
end

describe PagesCore::Plugin do
  let(:plugin) { TestPlugin }

  describe ".admin_menu_item" do
    let(:items) { PagesCore::AdminMenuItem.items }
    let(:item) { PagesCore::AdminMenuItem.new("Test", "foo", :custom, {} ) }
    it "should create a menu item" do
      expect(items).to include(item)
    end
  end

  describe ".plugins" do
    subject { PagesCore::Plugin.plugins }
    it { is_expected.to match_array([PagesCore::PagesPlugin, plugin]) }
  end
end
