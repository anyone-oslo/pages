# frozen_string_literal: true

require "rails_helper"

describe "feeds/pages" do
  before do
    assign(:items, [])
    without_partial_double_verification do
      allow(view).to receive(:root_url).and_return("http://test.host/")
    end
    render template: "feeds/pages", formats: [:rss]
  end

  it "renders the language as an element" do
    expect(rendered).to include("<language>#{I18n.locale}</language>")
  end
end
