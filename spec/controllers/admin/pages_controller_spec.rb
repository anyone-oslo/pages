# frozen_string_literal: true

require "rails_helper"

describe Admin::PagesController, type: :controller do
  let(:locale) { I18n.default_locale }
  let(:page) { create(:page) }
  let(:user) { create(:user) }

  before { login(user) }

  describe "GET index" do
    before do
      page
      create(:hidden_page)
      create(:deleted_page)
      get :index, params: { locale: locale }
    end

    it { is_expected.to render_template("admin/pages/index") }
  end

  describe "GET news" do
    context "without a news page" do
      before { get :news, params: { locale: locale } }

      it { is_expected.to redirect_to(admin_pages_url(locale)) }
    end

    context "with a news page" do
      let!(:root) { create(:page, news_page: true) }
      let!(:article1) { create(:page, parent: root) }

      before do
        create(:page, parent: root, published_at: 1.year.ago)
        get :news, params: { locale: locale, year: article1.published_at.year }
      end

      it { is_expected.to render_template("admin/pages/news") }

      it "sets the archive finder" do
        expect(assigns(:archive_finder)).to be_a(PagesCore::ArchiveFinder)
      end

      it "finds the page" do
        expect(assigns(:pages)).to eq([article1])
      end
    end
  end

  describe "GET new" do
    before { get :new, params: { locale: locale } }

    let(:page) { assigns(:page) }

    it { is_expected.to render_template("admin/pages/new") }

    it "initializes the page" do
      expect(page).to be_a(Page)
    end

    it "sets the author" do
      expect(page.author).to eq(user)
    end

    context "with parent" do
      let(:parent) { create(:page) }

      before { get :new, params: { locale: locale, parent: parent.id } }

      it "sets the parent" do
        expect(page.parent).to eq(parent)
      end
    end
  end

  describe "POST create" do
    let(:params) { { name: "Page name" } }

    before { post(:create, params: { locale: locale, page: params }) }

    it "redirects to the edit page" do
      expect(controller).to(
        redirect_to(edit_admin_page_url(locale, assigns(:page)))
      )
    end

    describe "the page" do
      subject { assigns(:page) }

      it { is_expected.to be_valid }
    end
  end

  describe "GET new_news" do
    before do
      create(:page, news_page: true)
      get :new_news, params: { locale: locale }
    end

    it { is_expected.to render_template("admin/pages/new") }
  end

  describe "GET show" do
    before { get :show, params: { locale: locale, id: page.id } }

    it "redirects to the edit page" do
      expect(controller).to(
        redirect_to(edit_admin_page_url(locale, page))
      )
    end
  end

  describe "GET edit" do
    before { get :edit, params: { locale: locale, id: page.id } }

    it { is_expected.to render_template("admin/pages/edit") }

    it "finds the page" do
      expect(assigns(:page)).to eq(page)
    end
  end

  describe "PUT move" do
    let(:parent) { create(:page) }
    let!(:other) { create(:page, parent: parent, position: 1) }

    before do
      put(:move, params: { id: page.id,
                           locale: locale,
                           parent_id: parent.id,
                           position: 1 })
      page.reload
      other.reload
    end

    it { is_expected.to redirect_to(admin_pages_url(locale)) }

    it "changes the parent" do
      expect(page.parent).to eq(parent)
    end

    it "changes the positions" do
      expect([page.position, other.position]).to eq([1, 2])
    end
  end
end
