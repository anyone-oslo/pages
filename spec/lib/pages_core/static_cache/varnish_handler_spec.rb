# frozen_string_literal: true

require "rails_helper"

describe PagesCore::StaticCache::VarnishHandler do
  subject(:handler) { described_class.new("http://varnish") }

  before { PagesCore::CacheSweeper.enabled = true }

  describe "#cache_page_permanently" do
    let(:controller) { instance_spy(ApplicationController) }
    let(:request) { ActionDispatch::TestRequest.create }
    let(:response) { ActionDispatch::TestResponse.new }

    it "tags the response" do
      handler.cache_page_permanently(controller, request, response,
                                     tags: ["attachment-12"])
      expect(response.headers["X-Cache-Tags"]).to eq("permanent attachment-12")
    end

    it "tags the response as permanent without other tags" do
      handler.cache_page_permanently(controller, request, response)
      expect(response.headers["X-Cache-Tags"]).to eq("permanent")
    end
  end

  describe "#purge_record!" do
    let(:attachment) { create(:attachment) }
    let(:ban) { instance_double(Typhoeus::Request, run: nil) }
    let(:pattern) do
      "(^|[[:space:]])attachment-#{attachment.id}([[:space:]]|$)"
    end

    before do
      allow(Typhoeus::Request).to receive(:new).and_return(ban)
      handler.purge_record!(attachment)
    end

    it "bans the record's cache tag" do
      expect(Typhoeus::Request).to have_received(:new).with(
        "http://varnish", method: :ban, headers: { "X-Cache-Tags": pattern }
      )
    end

    it "sends the ban" do
      expect(ban).to have_received(:run)
    end
  end
end
