# frozen_string_literal: true

require "rails_helper"

describe "Images" do
  include DynamicImage::Helper

  let(:image) { create(:image) }
  let(:cache_path) { Rails.public_path.join("cache") }
  let(:cached_files) do
    Dir.glob(cache_path.join("**/*")).select { |f| File.file?(f) }
  end

  before do
    PagesCore::CacheSweeper.enabled = true
    ImagesController.perform_caching = true
    FileUtils.rm_rf(cache_path)
  end

  after do
    ImagesController.perform_caching = false
    FileUtils.rm_rf(cache_path)
  end

  describe "GET show with a suffix after the ID" do
    let(:path) { dynamic_image_path(image, size: "10x10") }

    before { get path.sub(image.to_param, "#{image.id}-junk") }

    it "redirects to the canonical URL" do
      expect(response).to redirect_to(path)
    end

    it "redirects permanently" do
      expect(response).to have_http_status(:moved_permanently)
    end

    it "doesn't write a cache file" do
      expect(cached_files).to be_empty
    end
  end

  describe "GET show" do
    before { get dynamic_image_path(image, size: "10x10") }

    it "writes a cache file" do
      expect(cached_files).not_to be_empty
    end
  end

  context "with the Varnish handler" do
    let(:handler) do
      PagesCore::StaticCache::VarnishHandler.new("http://varnish")
    end

    before do
      allow(PagesCore::StaticCache).to receive(:handler).and_return(handler)
    end

    describe "GET show" do
      before { get dynamic_image_path(image, size: "10x10") }

      it "tags the response with the image's cache tag" do
        expect(response.headers["X-Cache-Tags"])
          .to eq("permanent image-#{image.id}")
      end
    end

    describe "GET download" do
      before { get download_dynamic_image_path(image) }

      it "tags the response with the image's cache tag" do
        expect(response.headers["X-Cache-Tags"])
          .to eq("permanent image-#{image.id}")
      end
    end

    describe "GET original" do
      before { get original_dynamic_image_path(image) }

      it "tags the response with the image's cache tag" do
        expect(response.headers["X-Cache-Tags"])
          .to eq("permanent image-#{image.id}")
      end
    end
  end
end
