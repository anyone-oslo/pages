# frozen_string_literal: true

require "rails_helper"

describe AttachmentsController do
  let(:attachment) { create(:attachment) }
  let(:content) { attachment.data }

  def get_attachment(action = :show, range: nil)
    request.headers["Range"] = range if range
    get action, params: { id: attachment.id, digest: attachment.digest }
  end

  describe "GET show" do
    before { get_attachment }

    it "responds with success" do
      expect(response).to have_http_status(:ok)
    end

    it "sends the data" do
      expect(response.body).to eq(content)
    end

    it "sends the record's content type" do
      expect(response.media_type).to eq("image/png")
    end

    it "sends inline" do
      expect(response.headers["Content-Disposition"]).to match("inline")
    end

    it "advertises range support" do
      expect(response.headers["Accept-Ranges"]).to eq("bytes")
    end
  end

  describe "GET download" do
    before { get_attachment(:download) }

    it "sends as an attachment" do
      expect(response.headers["Content-Disposition"]).to match("attachment")
    end

    it "sends the data" do
      expect(response.body).to eq(content)
    end
  end

  describe "a range request" do
    before { get_attachment(range: "bytes=10-29") }

    it "responds with partial content" do
      expect(response).to have_http_status(:partial_content)
    end

    it "sends only the requested bytes" do
      expect(response.body).to eq(content[10..29])
    end

    it "sets Content-Range" do
      expect(response.headers["Content-Range"])
        .to eq("bytes 10-29/#{content.bytesize}")
    end
  end

  describe "an unsatisfiable range request" do
    before { get_attachment(range: "bytes=#{content.bytesize + 1}-") }

    it "responds with 416" do
      expect(response).to have_http_status(:range_not_satisfiable)
    end

    it "reports the full size" do
      expect(response.headers["Content-Range"])
        .to eq("bytes */#{content.bytesize}")
    end
  end

  describe "with an invalid digest" do
    it "responds with not found" do
      get :show, params: { id: attachment.id, digest: "bogus" }
      expect(response).to have_http_status(:not_found)
    end
  end
end
