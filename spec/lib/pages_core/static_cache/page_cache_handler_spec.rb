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
