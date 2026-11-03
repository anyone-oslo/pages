# frozen_string_literal: true

require "rails_helper"

describe PagesCore::PermanentlyCached do
  let(:handler) { instance_spy(PagesCore::StaticCache::PageCacheHandler) }
  let(:gif) { Rails.root.join("../support/fixtures/image.gif") }

  before do
    allow(PagesCore::StaticCache).to receive(:handler).and_return(handler)
  end

  %i[attachment image].each do |factory|
    context "with #{factory}" do
      let!(:record) { create(factory) }

      it "has a cache tag" do
        expect(record.cache_tag).to eq("#{factory}-#{record.id}")
      end

      it "purges the record when destroyed" do
        record.destroy
        expect(handler).to have_received(:purge_record!).with(record)
      end

      it "purges the record when the file changes" do
        record.update(file: Rack::Test::UploadedFile.new(gif, "image/gif"))
        expect(handler).to have_received(:purge_record!).with(record)
      end

      it "doesn't purge the record when other attributes change" do
        record.update(updated_at: 1.day.from_now)
        expect(handler).not_to have_received(:purge_record!)
      end

      it "doesn't purge the record when created" do
        expect(handler).not_to have_received(:purge_record!)
      end
    end
  end
end
