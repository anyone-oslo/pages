# frozen_string_literal: true

require "rails_helper"

RSpec.describe PagesCore::FeedTagsHelper do
  describe "#feed_tags" do
    subject(:tags) { helper.feed_tags(options) }

    let(:options) { {} }
    let!(:feed) { create(:page, name: "News", feed_enabled: true) }

    before do
      PagesCore.config.localizations = false
      PagesCore.configure { |c| c.site_name = "Test Site" }
    end

    it { is_expected.to include('title="Test Site"') }
    it { is_expected.to include(helper.page_url(I18n.default_locale, feed, format: :rss)) }

    context "with include_hidden" do
      let(:options) { { include_hidden: true } }
      let!(:hidden) { create(:hidden_page, name: "Hidden", feed_enabled: true) }

      it { is_expected.to include(helper.page_url(I18n.default_locale, feed, format: :rss)) }
      it { is_expected.not_to include(helper.page_url(I18n.default_locale, hidden, format: :rss)) }
    end

    context "with include_hidden when only hidden feeds exist" do
      let(:options) { { include_hidden: true } }
      let(:feed) { create(:hidden_page, name: "Hidden", feed_enabled: true) }

      it { is_expected.to include('title="Test Site"') }
      it { is_expected.not_to include(helper.page_url(I18n.default_locale, feed, format: :rss)) }
    end

    context "when the feed page is scheduled for autopublish" do
      let(:feed) do
        create(:page, feed_enabled: true, autopublish: true,
                      published_at: 1.day.from_now)
      end

      it { is_expected.not_to include(helper.page_url(I18n.default_locale, feed, format: :rss)) }
    end
  end
end
