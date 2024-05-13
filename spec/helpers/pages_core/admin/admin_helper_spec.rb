# frozen_string_literal: true

require "rails_helper"

RSpec.describe PagesCore::Admin::AdminHelper do
  describe "#content_tab" do
    subject!(:tab) { helper.content_tab(:foo) { "Content" } }

    let(:tabs) { helper.content_tabs }

    it "renders the tab" do
      expect(tab).to(
        eq("<div class=\"content-tab\" id=\"content-tab-foo\" " \
           "role=\"tabpanel\" data-tab=\"foo\">Content</div>")
      )
    end

    it "stores the tab" do
      expect(tabs.first[:name]).to eq("Foo")
    end
  end
end
