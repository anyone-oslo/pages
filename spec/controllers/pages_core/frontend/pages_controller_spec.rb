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

    it "calls the template actions" do
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

    context "with a nonexistant template" do
      let(:page) { create(:page, name: "Home", template: "foo") }

      it { is_expected.to render_template("pages/templates/index") }
    end

    describe "RSS rendering" do
      let(:params) { { path: page.path_segment, format: :rss } }

      it { is_expected.to render_template("feeds/pages") }
    end

    describe "JSON rendering" do
      let(:params) { { path: page.path_segment, format: :json } }
      let(:json) { response.parsed_body }

      it "renders the page as json" do
        expect(json["name"]).to eq("Home")
      end
    end
  end
end
