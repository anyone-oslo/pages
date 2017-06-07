# encoding: utf-8

require "rails_helper"

class SweepableTestModel
  extend ActiveModel::Callbacks
  define_model_callbacks :save, :destroy
end

describe PagesCore::CacheSweeper do
  let(:singleton) { PagesCore::CacheSweeper }
  let(:cache_path) { Rails.root.join("public", "cache") }

  before do
    PagesCore::CacheSweeper.enabled = true
    ActionController::Base.page_cache_directory = cache_path
    FileUtils.rm_rf(cache_path) if File.exist?(cache_path)
    FileUtils.mkdir_p(cache_path)
  end

  describe ".disable" do
    it "should disable the sweeper" do
      allow(singleton).to receive(:sweep_dir)
      singleton.disable do
        singleton.sweep!
      end
      expect(singleton).not_to have_received(:sweep_dir)
    end

    it "should reset the enabled value" do
      singleton.disable do
        expect(singleton.enabled).to eq(false)
      end
      expect(singleton.enabled).to eq(true)
    end
  end

  describe ".once" do
    it "should perform the sweep do" do
      allow(PagesCore::SweepCacheJob).to receive(:perform_later)
      singleton.once do
        expect(singleton.enabled).to eq(false)
      end
      expect(PagesCore::SweepCacheJob).to have_received(:perform_later).once
    end
  end

  describe ".config" do
    subject { singleton.config }

    it { is_expected.to be_an(OpenStruct) }

    context "with a block" do
      it "should yield the config object" do
        singleton.config do |config|
          expect(config).to be_an(OpenStruct)
          expect(config).to eq(singleton.config)
        end
      end
    end
  end

  describe ".purge!" do
    let(:test_file) { cache_path.join("file.txt") }
    before { FileUtils.touch(test_file) }

    it "should delete all files" do
      singleton.purge!
      expect(File.exist?(test_file)).to eq(false)
    end
  end

  describe ".sweep!" do
    let(:filename) { "foo.png" }
    let(:path) { cache_path.join(filename) }

    before do
      FileUtils.mkdir_p(File.dirname(path))
      FileUtils.touch(path)
    end

    subject do
      singleton.sweep!
      File.exist?(path)
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
      let!(:page) { create(:page, name: "Home") }
      let(:filename) { "home.html" }
      it { is_expected.to eq(false) }
    end
  end
end
