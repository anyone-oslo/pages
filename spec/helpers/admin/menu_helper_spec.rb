# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::MenuHelper, type: :helper do
  before { helper.instance_variable_set(:@locale, I18n.default_locale) }

  describe "#header_tabs" do
    subject(:tabs) { helper.header_tabs(:pages) }

    let(:pattern) do
      "<ul class=\"pages\"><li><a class=\"\" " \
      "href=\"/admin/nb/pages/news\">News</a></li>" \
      "<li><a class=\"current\" href=\"/admin/nb/pages\">" \
      "Pages</a></li></ul>"
    end

    before { create(:page, news_page: true) }

    it "renders the tabs" do
      allow(helper).to receive(:params)
        .and_return(controller: "admin/pages", action: "index")
      expect(tabs).to eq(pattern)
    end
  end
end
