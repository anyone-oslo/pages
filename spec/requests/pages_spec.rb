# frozen_string_literal: true

require "rails_helper"

describe "Pages" do
  let!(:page) { create(:page, name: "Home") }
  let(:cache_path) { Rails.public_path.join("static_cache") }
  let(:cached_files) do
    Dir.glob(cache_path.join("**/*")).select { |f| File.file?(f) }
  end

  before do
    PagesCore.config.localizations = false
    PagesCore::CacheSweeper.enabled = true
    PagesController.perform_caching = true
    FileUtils.rm_rf(cache_path)
  end

  after do
    PagesController.perform_caching = false
    FileUtils.rm_rf(cache_path)
  end

  context "with a suffix after the ID and tracking parameters" do
    before { get "/nb/pages/#{page.id}-junk.json?utm_source=x&fbclid=y" }

    it "redirects to the canonical URL with the tracking parameters" do
      expect(response).to redirect_to("/home.json?fbclid=y&utm_source=x")
    end

    it "doesn't write a cache file" do
      expect(cached_files).to be_empty
    end
  end

  context "with a suffix after the ID and other parameters" do
    before { get "/nb/pages/#{page.id}-junk.json?per_page=1" }

    it "doesn't redirect" do
      expect(response).to have_http_status(:ok)
    end

    it "doesn't write a cache file" do
      expect(cached_files).to be_empty
    end
  end

  context "with a suffix after the ID on a paginated URL" do
    before { get "/nb/pages/#{page.id}-junk/7.json" }

    it "redirects to the canonical paginated URL" do
      expect(response).to redirect_to("/home/page/7.json")
    end

    it "doesn't write a cache file" do
      expect(cached_files).to be_empty
    end
  end

  context "with a canonical paginated URL" do
    before { get "/home/page/7.json" }

    it "responds with success" do
      expect(response).to have_http_status(:ok)
    end

    it "writes a cache file" do
      expect(cached_files).to include(cache_path.join("home/page/7.json").to_s)
    end
  end
end
