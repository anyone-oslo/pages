# frozen_string_literal: true

require "rails_helper"

RSpec.describe PagesCore::HeadTagsHelper do
  describe "#pages_meta_tags" do
    before { PagesCore.configure { |c| c.site_name = "Test Site" } }

    it "renders without raising when the request URL has BINARY encoding" do
      # Some clients (e.g. crawlers) send non-URL-encoded UTF-8 bytes in the
      # query string. Rack exposes QUERY_STRING as ASCII-8BIT, so request.url
      # ends up BINARY with non-ASCII bytes. Without forcing UTF-8 here, that
      # poisons the ERB output buffer's encoding and later tags raise
      # Encoding::CompatibilityError.
      helper.request.env["QUERY_STRING"] = "q=Jørgen Moltubak".b
      output = helper.pages_meta_tags
      expect(output.encoding).to eq(Encoding::UTF_8)
    end
  end
end
