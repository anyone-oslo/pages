require "rails_helper"

describe PagesCore::Frontend::PagesController, type: :controller do
  controller(PagesController) do
  end

  let(:locale) { I18n.default_locale }
  let(:page) { create(:page, name: "Home", template: "news_item") }

  before { PagesCore.config.localizations = false }

  describe "GET index" do
    context "when no root pages exist" do
      before { get :index }
      it { is_expected.to render_template("errors/404") }
    end

    context "when a page exists" do
      let!(:page) { create(:page, template: "news_item") }
      before { get :index }

      it { is_expected.to render_template("pages/templates/news_item") }

      it "finds the page" do
        expect(assigns(:page)).to eq(page)
      end
    end

    context "when rendering RSS" do
      before do
        create(:page, template: "news_item", feed_enabled: true)
        get :index, params: { format: :rss }
      end

      it { is_expected.to render_template("feeds/pages") }

      it "sets the content type" do
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
      get :show, params: params
    end

    let(:params) { { path: page.path_segment } }

    it { is_expected.to render_template("pages/templates/home") }

    it "sets the document title" do
      expect(assigns(:document_title)).to eq("Home")
    end

    it "calls the template render proc" do
      expect(assigns(:home_page)).to eq(page)
    end

    context "when page redirects" do
      let(:page) { create(:page, redirect_to: "http://anyone.no") }
      let(:params) { { id: page.id, locale: locale } }

      it { is_expected.to redirect_to("http://anyone.no") }
    end

    context "when page does not exist" do
      let(:params) { { id: 123, locale: locale } }

      it { is_expected.to render_template("errors/404") }
    end

    context "when requested by ID" do
      let(:params) { { id: page.id, locale: locale } }

      it { is_expected.to redirect_to("/home") }
    end

    context "when path is outdated" do
      let(:params) do
        PagePath.associate(page, locale: locale, path: "foo")
        { path: "foo" }
      end

      it { is_expected.to redirect_to("/home") }
    end

    context "when page is hidden" do
      let(:page) { create(:page, name: "Home", status: 3) }

      it { is_expected.to render_template("errors/404") }
    end

    context "when page has a meta title" do
      let(:page) { create(:page, name: "Home", meta_title: "Meta") }

      it "sets the document title" do
        expect(assigns(:document_title)).to eq("Meta")
      end
    end

    describe "page rendering with a nonexistant template" do
      let(:page) { create(:page, name: "Home", template: "foo") }

      it "raises an error" do
        expect { get :show, path: page.path_segment }
          .to raise_error(PagesCore::Template::NotFoundError)
      end
    end

    describe "RSS rendering" do
      let(:params) { { path: page.path_segment, format: :rss } }

      it { is_expected.to render_template("feeds/pages") }
    end

    describe "JSON rendering" do
      let(:params) { { path: page.path_segment, format: :json } }

      it "renders the page as json" do
        page.reload
        expect(response.body).to eq(PageSerializer.new(page).to_json)
      end
    end
  end
end
