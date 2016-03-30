require "rails_helper"

describe Admin::PagesController, type: :controller do
  let(:locale) { I18n.default_locale }
  let(:page) { create(:page) }
  let(:user) { create(:user) }

  before { login(user) }

  describe "GET index" do
    let!(:page) { create(:page) }
    let!(:hidden) { create(:hidden_page) }
    let!(:deleted) { create(:deleted_page) }

    before { get :index, locale: locale }

    it { is_expected.to render_template("admin/pages/index") }

    it "should load the root pages" do
      expect(assigns(:root_pages)).to match_array([page, hidden])
    end
  end

  describe "GET news" do
    context "without a news page" do
      before { get :news, locale: locale }
      it { is_expected.to redirect_to(admin_pages_url(locale)) }
    end

    context "with a news page" do
      let!(:root) { create(:page, news_page: true) }
      let!(:article1) { create(:page, parent: root) }
      let!(:article2) { create(:page, parent: root, published_at: 2.months.ago) }
      before { get :news, locale: locale }

      it { is_expected.to render_template("admin/pages/news") }

      it "should set the archive finder" do
        expect(assigns(:archive_finder)).to be_a(PagesCore::ArchiveFinder)
      end

      it "should default to the current month" do
        expect(assigns(:year)).to eq(Time.zone.now.year)
        expect(assigns(:month)).to eq(Time.zone.now.month)
      end

      it "should find the page" do
        expect(assigns(:pages)).to eq([article1])
      end
    end
  end

  describe "GET new" do
    before { get :new, locale: locale }
    let(:page) { assigns(:page) }

    it { is_expected.to render_template("admin/pages/new") }

    it "should set authors" do
      expect(assigns(:authors)).to eq([user])
    end

    it "should initialize the page" do
      expect(page).to be_a(Page)
      expect(page.author).to eq(user)
    end

    context "with parent" do
      let(:parent) { create(:page) }
      before { get :new, locale: locale, parent: parent.id }

      it "should set the parent" do
        expect(page.parent).to eq(parent)
      end
    end
  end

  describe "POST create" do
    let(:params) { { name: "Page name" } }
    before { post(:create, locale: locale, page: params) }

    it "should redirect to the edit page" do
      expect(subject).to(
        redirect_to(edit_admin_page_url(locale, assigns(:page)))
      )
    end

    describe "the page" do
      subject { assigns(:page) }

      it { is_expected.to be_valid }
    end
  end

  describe "GET new_news" do
    let!(:root) { create(:page, news_page: true) }
    before { get :new_news, locale: locale }
    it { is_expected.to render_template("admin/pages/new") }
  end

  describe "GET show" do
    before { get :show, locale: locale, id: page.id }
    it { is_expected.to render_template("admin/pages/edit") }

    it "should find the page" do
      expect(assigns(:page)).to eq(page)
    end

    it "should find authors" do
      expect(assigns(:authors).any?).to eq(true)
    end
  end

  describe "GET edit" do
    before { get :edit, locale: locale, id: page.id }
    it { is_expected.to render_template("admin/pages/edit") }

    it "should find the page" do
      expect(assigns(:page)).to eq(page)
    end

    describe "@authors" do
      let(:deactivated) { create(:user, activated: false) }
      let(:page) { create(:page, author: deactivated) }
      subject { assigns(:authors) }
      it { is_expected.to match_array([user, deactivated]) }
    end
  end

  describe "PUT move" do
    let(:parent) { create(:page) }
    let!(:other) { create(:page, parent: parent, position: 1) }

    before do
      put :move, id: page.id, locale: locale, parent_id: parent.id, position: 1
      page.reload
      other.reload
    end

    it { is_expected.to redirect_to(admin_pages_url(locale)) }

    it "should change the parent" do
      expect(page.parent).to eq(parent)
    end

    it "should change the positions" do
      expect(page.position).to eq(1)
      expect(other.position).to eq(2)
    end
  end
end
