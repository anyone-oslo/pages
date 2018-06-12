require "rails_helper"

class SweepableTestModel
  extend ActiveModel::Callbacks
  define_model_callbacks :save, :destroy
end

describe PagesCore::CacheSweeper do
  let(:singleton) { described_class }
  let(:cache_path) { Rails.root.join("public", "cache") }

  before do
    described_class.enabled = true
    ActionController::Base.page_cache_directory = cache_path
    FileUtils.rm_rf(cache_path) if File.exist?(cache_path)
    FileUtils.mkdir_p(cache_path)
  end

  describe ".disable" do
    it "disables the sweeper" do
      allow(singleton).to receive(:sweep_dir)
      singleton.disable do
        singleton.sweep!
      end
      expect(singleton).not_to have_received(:sweep_dir)
    end

    it "resets the enabled value" do
      singleton.disable {}
      expect(singleton.enabled).to eq(true)
    end
  end

  describe ".once" do
    it "performs the sweep" do
      allow(PagesCore::SweepCacheJob).to receive(:perform_later)
      singleton.once {}
      expect(PagesCore::SweepCacheJob).to have_received(:perform_later).once
    end
  end

  describe ".config" do
    subject { singleton.config }

    it { is_expected.to be_an(OpenStruct) }

    context "with a block" do
      it "yields the config object" do
        singleton.config do |config|
          expect(config).to eq(singleton.config)
        end
      end
    end
  end

  describe ".purge!" do
    let(:test_file) { cache_path.join("file.txt") }

    before { FileUtils.touch(test_file) }

    it "deletes all files" do
      singleton.purge!
      expect(File.exist?(test_file)).to eq(false)
    end
  end

  describe ".sweep!" do
    subject do
      singleton.sweep!
      File.exist?(path)
    end

    let(:filename) { "foo.png" }
    let(:path) { cache_path.join(filename) }

    before do
      FileUtils.mkdir_p(File.dirname(path))
      FileUtils.touch(path)
    end

    context "with a non-matching filename" do
      let(:filename) { "home.html" }

      it { is_expected.to eq(true) }
    end

    context "with a matching filename" do
      let(:filename) { "index.html" }

      it { is_expected.to eq(false) }
    end

    context "with a matching path" do
      let(:filename) { "nb/index.html" }

      it { is_expected.to eq(false) }
    end

    context "with a matching page path" do
      let(:filename) { "home.html" }

      before { create(:page, name: "Home") }

      it { is_expected.to eq(false) }
    end
  end
end
