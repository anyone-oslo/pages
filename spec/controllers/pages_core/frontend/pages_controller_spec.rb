# frozen_string_literal: true

require "rails_helper"

describe PagesCore::Frontend::PagesController do
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

      it "finds the page" do
        expect(assigns(:page)).to eq(page)
      end
    end

    context "when rendering RSS" do
      before do
        create(:page, template: "home", feed_enabled: true)
        get :index, params: { format: :rss }
      end

      it { is_expected.to render_template("feeds/pages") }

      it "sets the content type" do
        expect(response.content_type).to(
          eq("application/rss+xml; charset=utf-8")
        )
      end
    end
  end

  shared_context "when requesting a page" do
    before do
      routes.draw do
        resources :pages, path: ":locale/pages"
        get(":locale/*path" => "pages#show")
        get("*path" => "pages#show")
      end
      get :show, params:
    end
  end

  describe "GET show" do
    include_context "when requesting a page"

    let(:params) { { path: page.path_segment } }

    it { is_expected.to render_template("pages/templates/home") }

    it "sets the document title" do
      expect(assigns(:document_title)).to eq("Home")
    end

    it "calls the template actions" do
      expect(assigns(:home_page)).to eq(page)
    end

    context "when page redirects" do
      let(:page) { create(:page, redirect_to: "http://anyone.no") }
      let(:params) { { id: page.id, locale: } }

      it { is_expected.to redirect_to("http://anyone.no") }
    end

    context "when page does not exist" do
      let(:params) { { id: 123, locale: } }

      it { is_expected.to render_template("errors/404") }
    end

    context "when requested by ID" do
      let(:params) { { id: page.id, locale: } }

      it { is_expected.to redirect_to("/home") }
    end

    context "when requested by ID with a suffix and an extension" do
      let(:params) { { id: "#{page.id}-junk", locale:, format: :html } }

      it { is_expected.to redirect_to("/home") }
    end

    context "when requested by ID with a suffix as JSON" do
      let(:params) { { id: "#{page.id}-junk", locale:, format: :json } }

      it { is_expected.to redirect_to("/home.json") }
    end

    context "when requested by ID with a suffix as RSS" do
      let(:params) { { id: "#{page.id}-junk", locale:, format: :rss } }

      it { is_expected.to redirect_to("/home.rss") }
    end

    context "when the path has an HTML extension" do
      let(:params) { { path: page.path_segment, format: :html } }

      it { is_expected.to redirect_to("/home") }
    end

    context "when path is outdated" do
      let(:params) do
        PagePath.associate(page, locale:, path: "foo")
        { path: "foo" }
      end

      it { is_expected.to redirect_to("/home") }
    end

    context "when page is hidden" do
      let(:page) { create(:page, name: "Home", status: 3) }

      it { is_expected.to render_template("errors/404") }
    end

    context "when hidden page is requested by ID" do
      let(:page) { create(:page, name: "Home", status: 3) }
      let(:params) { { id: page.id, locale: } }

      it { is_expected.to render_template("errors/404") }
    end

    context "when page has a meta title" do
      let(:page) { create(:page, name: "Home", meta_title: "Meta") }

      it "sets the document title" do
        expect(assigns(:document_title)).to eq("Meta")
      end
    end

    context "with a nonexistant template" do
      let(:page) { create(:page, name: "Home", template: "foo") }

      it { is_expected.to render_template("pages/templates/index") }
    end
  end

  describe "RSS rendering" do
    include_context "when requesting a page"

    let(:params) { { path: page.path_segment, format: :rss } }

    context "when page is feed enabled" do
      let(:page) { create(:page, name: "Home", feed_enabled: true) }

      it { is_expected.to render_template("feeds/pages") }
    end

    context "with a large per_page" do
      let(:page) { create(:page, name: "Home", feed_enabled: true) }
      let(:params) { { path: page.path_segment, format: :rss, per_page: "1000" } }

      it "limits the number of items to 100" do
        expect(assigns(:items).per_page).to eq(100)
      end
    end

    context "with a page number out of range" do
      let(:page) { create(:page, name: "Home", feed_enabled: true) }
      let(:params) do
        { path: page.path_segment, format: :rss,
          page: "10000000000000000000000000" }
      end

      specify { expect(response).to have_http_status(:ok) }

      it "limits the page number to 10000" do
        expect(assigns(:items).current_page).to eq(10_000)
      end
    end

    context "when page isn't feed enabled" do
      specify { expect(response).to have_http_status(:not_found) }
    end

    context "when page is hidden" do
      let(:page) do
        create(:page, name: "Home", feed_enabled: true, status: 3)
      end

      specify { expect(response).to have_http_status(:not_found) }
    end
  end

  describe "JSON rendering" do
    include_context "when requesting a page"

    let(:params) { { path: page.path_segment, format: :json } }
    let(:json) { response.parsed_body }

    it "renders the page as json" do
      expect(json["name"]).to eq("Home")
    end

    context "with a page number" do
      let(:params) { { path: page.path_segment, format: :json, page: "2" } }

      it "is static cached" do
        expect(controller.static_cached?).to be(true)
      end
    end

    context "with a page number out of range" do
      let(:params) do
        { path: page.path_segment, format: :json, page: "999999" }
      end

      it "isn't static cached" do
        expect(controller.static_cached?).to be(false)
      end
    end

    context "with an invalid page number" do
      let(:params) { { path: page.path_segment, format: :json, page: "foo" } }

      it "isn't static cached" do
        expect(controller.static_cached?).to be(false)
      end
    end

    context "when page is a draft" do
      let(:page) { create(:page, name: "Home", status: 0) }

      specify { expect(response).to have_http_status(:not_found) }
    end

    context "when page is hidden" do
      let(:page) { create(:page, name: "Home", status: 3) }

      specify { expect(response).to have_http_status(:not_found) }
    end

    context "when page is deleted" do
      let(:page) { create(:page, name: "Home", status: 4) }
      let(:params) { { id: page.id, locale:, format: :json } }

      specify { expect(response).to have_http_status(:not_found) }
    end

    context "when page is scheduled for autopublish" do
      let(:page) do
        create(:page, name: "Home", autopublish: true,
                      published_at: 1.day.from_now)
      end

      specify { expect(response).to have_http_status(:not_found) }
    end
  end
end
