# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Page templates", type: :system do
  subject { page }

  let(:page_model) do
    create(:page,
           template:,
           headline: "My headline",
           body: "My body",
           excerpt: "My excerpt")
  end
  let(:template) { "index" }
  let(:locale) { I18n.default_locale }

  before do
    visit page_path(locale, page_model)
  end

  describe "default template" do
    it { is_expected.to have_text(page_model.headline) }
    it { is_expected.to have_text(page_model.body) }
  end
end
