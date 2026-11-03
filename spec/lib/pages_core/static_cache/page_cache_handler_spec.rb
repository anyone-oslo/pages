# frozen_string_literal: true

require "rails_helper"

describe PagesCore::StaticCache::PageCacheHandler do
  subject(:handler) { described_class.new }

  let(:cache_path) { Rails.public_path.join("static_cache") }
  let(:singleton) { described_class }

  before do
    PagesCore::CacheSweeper.enabled = true
    FileUtils.rm_rf(cache_path)
    FileUtils.mkdir_p(cache_path)
  end

  describe "#cache_page" do
    let(:controller) { instance_spy(ApplicationController) }
    let(:request) { instance_double(ActionDispatch::Request, query_parameters:) }

    before do
      allow(controller).to receive(:class)
        .and_return(class_spy(ApplicationController))
      handler.cache_page(controller, request, nil)
    end

    context "without a query string" do
      let(:query_parameters) { {} }

      it { expect(controller).to have_received(:cache_page) }
    end

    context "with tracking parameters" do
      let(:query_parameters) do
        { "utm_source" => "x", "gclid" => "y", "fbclid" => "z" }
      end

      it { expect(controller).to have_received(:cache_page) }
    end

    context "with other parameters" do
      let(:query_parameters) { { "utm_source" => "x", "per_page" => "1" } }

      it { expect(controller).not_to have_received(:cache_page) }
    end
  end

  describe "#cache_page_permanently" do
    let(:controller) { instance_spy(ApplicationController) }
    let(:request) { instance_double(ActionDispatch::Request, query_parameters:) }

    before do
      allow(controller).to receive(:class)
        .and_return(class_spy(ApplicationController))
      handler.cache_page_permanently(controller, request, nil)
    end

    context "without a query string" do
      let(:query_parameters) { {} }

      it { expect(controller).to have_received(:cache_page) }
    end

    context "with other parameters" do
      let(:query_parameters) { { "size" => "1" } }

      it { expect(controller).not_to have_received(:cache_page) }
    end
  end

  describe "#purge_record!" do
    def permanent_path
      Rails.public_path.join("cache")
    end

    def cache_file(path)
      permanent_path.join(path).tap do |file|
        FileUtils.mkdir_p(File.dirname(file))
        FileUtils.touch(file)
      end
    end

    after { FileUtils.rm_rf(permanent_path) }

    context "with an attachment" do
      let(:attachment) { create(:attachment) }
      let!(:other_file) do
        cache_file("attachments/#{create(:attachment).digest}/2-x.png")
      end

      before do
        cache_file("attachments/#{attachment.digest}/1-x.png")
        handler.purge_record!(attachment)
      end

      it "deletes the attachment's files" do
        expect(File.exist?(permanent_path.join("attachments", attachment.digest)))
          .to be(false)
      end

      it "keeps other attachments' files" do
        expect(File.exist?(other_file)).to be(true)
      end
    end

    context "with an image" do
      let(:image) { create(:image) }
      let!(:files) do
        [cache_file("dynamic_images/a/100x100/#{image.id}-1.png"),
         cache_file("dynamic_images/b/100x100/#{image.id}-1/uncropped.png"),
         cache_file("dynamic_images/c/#{image.id}-1/original.png")]
      end
      let(:other_file) do
        permanent_path.join("dynamic_images/d/100x100/#{image.id}0-1.png")
      end

      before do
        cache_file(other_file)
        handler.purge_record!(image)
      end

      it "deletes the image's files" do
        expect(files.map { |f| File.exist?(f) }).to all(be(false))
      end

      it "keeps other images' files" do
        expect(File.exist?(other_file)).to be(true)
      end
    end
  end

  describe ".purge!" do
    let(:test_file) { cache_path.join("file.txt") }

    before { FileUtils.touch(test_file) }

    it "deletes all files" do
      handler.purge!
      expect(File.exist?(test_file)).to be(false)
    end
  end

  describe ".sweep_now!" do
    subject do
      handler.sweep_now!
      File.exist?(path)
    end

    let(:filename) { "foo.png" }
    let(:path) { cache_path.join(filename) }

    before do
      FileUtils.mkdir_p(File.dirname(path))
      FileUtils.touch(path)
    end

    context "with a matching filename" do
      let(:filename) { "index.html" }

      it { is_expected.to be(false) }
    end

    context "with a matching path" do
      let(:filename) { "nb/index.html" }

      it { is_expected.to be(false) }
    end

    context "with a matching page path" do
      let(:filename) { "home.html" }

      before { create(:page, name: "Home") }

      it { is_expected.to be(false) }
    end

    context "with a paginated page path" do
      let(:filename) { "home/page/2.html" }

      before { create(:page, name: "Home") }

      it { is_expected.to be(false) }
    end
  end
end
