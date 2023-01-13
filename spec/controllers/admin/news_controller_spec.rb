# frozen_string_literal: true

require "rails_helper"

describe Admin::NewsController do
  let(:locale) { I18n.default_locale }
  let(:page) { create(:page) }
  let(:user) { create(:user) }

  before { login(user) }

  describe "GET index" do
    context "without a news page" do
      before { get :index, params: { locale: locale } }

      it { is_expected.to redirect_to(admin_pages_url(locale)) }
    end

    context "with a news page" do
      let!(:root) { create(:page, news_page: true) }
      let!(:article1) { create(:page, parent: root) }

      before do
        create(:page, parent: root, published_at: 1.year.ago)
        get :index, params: { locale: locale, year: article1.published_at.year }
      end

      it { is_expected.to render_template("admin/news/index") }

      it "sets the archive finder" do
        expect(assigns(:archive_finder)).to be_a(PagesCore::ArchiveFinder)
      end

      it "finds the page" do
        expect(assigns(:pages)).to eq([article1])
      end
    end
  end
end
