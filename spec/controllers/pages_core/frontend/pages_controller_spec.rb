require "rails_helper"

describe PagesCore::Frontend::PagesController, type: :controller do
  controller(PagesController) do
    template(:home) do |page|
      @home_page = page
    end
  end

  let(:locale) { I18n.default_locale }
  let(:page) { create(:page, name: "Home", template: "home") }

  before { PagesCore.config.localizations = false }

  describe "GET index" do
    context "when no root pages exist" do
      before { get :index }
      it { is_expected.to render_template("errors/404") }
    end

    context "when a page exists" do
      let!(:page) { create(:page, template: "home") }
      before { get :index }

      it { is_expected.to render_template("pages/templates/home") }

      it "should find the page" do
        expect(assigns(:page)).to eq(page)
      end
    end

    context "rendering RSS" do
      let!(:page) { create(:page, template: "home", feed_enabled: true) }
      before { get :index, params: { format: :rss } }

      it { is_expected.to render_template("feeds/pages") }

      it "should set the content type" do
        expect(response.content_type).to eq("application/rss+xml")
      end
    end
  end

  describe "GET show" do
    before do
      routes.draw do
        resources :pages, path: ":locale/pages"
        get(":locale/*path" => "pages#show")
        get("*path" => "pages#show")
      end
    end

    context "when page redirects" do
      let(:page) { create(:page, redirect_to: "http://kord.no") }
      before { get :show, params: { id: page.id, locale: locale } }
      it { is_expected.to redirect_to("http://kord.no") }
    end

    context "when page does not exist" do
      before { get :show, params: { id: 123, locale: locale } }
      it { is_expected.to render_template("errors/404") }
    end

    describe "URL canonicalization" do
      context "with ID" do
        before { get :show, params: { id: page.id, locale: locale } }
        it { is_expected.to redirect_to("/home") }
      end

      context "with outdated path" do
        let!(:path) do
          PagePath.associate(page, locale: locale, path: "foo")
        end
        before { get :show, params: { path: "foo" } }
        it { is_expected.to redirect_to("/home") }
      end

      context "with proper path" do
        before { get :show, params: { path: page.path_segment } }
        it { is_expected.to render_template("pages/templates/home") }
      end
    end

    describe "page rendering" do
      before { get :show, params: { path: page.path_segment } }

      context "if page is hidden" do
        let!(:page) { create(:page, name: "Home", status: 3) }
        it { is_expected.to render_template("errors/404") }
      end

      it "should set the document title" do
        expect(assigns(:document_title)).to eq("Home")
      end

      context "when page has a meta title" do
        let!(:page) { create(:page, name: "Home", meta_title: "Meta") }

        it "should set the document title" do
          expect(assigns(:document_title)).to eq("Meta")
        end
      end

      it "should call the template actions" do
        expect(assigns(:home_page)).to eq(page)
      end

      it { is_expected.to render_template("pages/templates/home") }

      context "with a nonexistant template" do
        let(:page) { create(:page, name: "Home", template: "foo") }
        it { is_expected.to render_template("pages/templates/index") }
      end
    end

    describe "RSS rendering" do
      before { get :show, params: { path: page.path_segment, format: :rss } }
      it { is_expected.to render_template("feeds/pages") }
    end

    describe "JSON rendering" do
      before { get :show, params: { path: page.path_segment, format: :json } }
      it "should render the page as json" do
        page.reload
        expect(response.body).to eq(PageSerializer.new(page).to_json)
      end
    end
  end
end
