# frozen_string_literal: true

require "rails_helper"

describe PagesCore::Configuration::Pages do
  subject(:config) { described_class.new }

  describe "#rate_limit_store" do
    before { allow(Rails).to receive(:cache).and_return(cache) }

    context "when Rails.cache is any other store" do
      let(:cache) { ActiveSupport::Cache::MemoryStore.new }

      it { expect(config.rate_limit_store).to eq(cache) }
    end

    context "when Rails.cache is a FileStore" do
      let(:cache) { ActiveSupport::Cache::FileStore.new(Dir.tmpdir) }

      it { expect(config.rate_limit_store).to be_a(ActiveSupport::Cache::MemoryStore) }
      it { expect(config.rate_limit_store).to equal(config.rate_limit_store) }
    end

    context "when Rails.cache is a NullStore" do
      let(:cache) { ActiveSupport::Cache::NullStore.new }

      it { expect(config.rate_limit_store).to be_a(ActiveSupport::Cache::MemoryStore) }
    end

    context "when a store is set" do
      let(:cache) { ActiveSupport::Cache::MemoryStore.new }
      let(:store) { ActiveSupport::Cache::MemoryStore.new }

      before { config.rate_limit_store(store) }

      it { expect(config.rate_limit_store).to equal(store) }
    end
  end
end
