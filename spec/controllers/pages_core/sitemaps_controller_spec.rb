# frozen_string_literal: true

require "rails_helper"

describe PagesCore::SitemapsController do
  describe "GET pages" do
    subject { response }

    before { get :pages, params: { locale:, format: :xml } }

    context "with the default locale" do
      let(:locale) { "nb" }

      it { is_expected.to have_http_status(:ok) }
    end

    context "with an unconfigured locale" do
      let(:locale) { "anything" }

      it { is_expected.to have_http_status(:not_found) }
    end
  end

  describe "GET pages with configured locales" do
    subject { response }

    before do
      PagesCore.config.locales = { "nb" => "Norsk", "en" => "English" }
      get :pages, params: { locale:, format: :xml }
    end

    after { PagesCore.config.locales = nil }

    context "with a configured locale" do
      let(:locale) { "en" }

      it { is_expected.to have_http_status(:ok) }
    end

    context "with an unconfigured locale" do
      let(:locale) { "de" }

      it { is_expected.to have_http_status(:not_found) }
    end
  end
end
