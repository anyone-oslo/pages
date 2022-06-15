# frozen_string_literal: true

require "rails_helper"

describe PagesCore::CacheSweeper do
  let(:singleton) { described_class }
  let(:cache_path) { Rails.public_path.join("cache") }
  let(:handler) { PagesCore.config.static_cache_handler }

  before do
    described_class.enabled = true
  end

  describe ".disable" do
    it "disables the sweeper" do
      singleton.disable do
        expect(singleton.enabled).to be(false)
      end
    end

    it "resets the enabled value" do
      singleton.disable
      expect(singleton.enabled).to be(true)
    end
  end

  describe ".once" do
    it "performs the sweep" do
      allow(PagesCore::SweepCacheJob).to receive(:perform_later)
      singleton.once
      expect(PagesCore::SweepCacheJob).to have_received(:perform_later).once
    end
  end
end
