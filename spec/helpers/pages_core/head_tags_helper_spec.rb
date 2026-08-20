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

    context "with an image" do
      let(:image) { create(:image) }
      let(:page) { create(:page, meta_image: image) }

      it "renders the image width" do
        expect(helper.pages_meta_tags(page))
          .to include('<meta property="og:image:width" content="320">')
      end

      it "renders the image height" do
        expect(helper.pages_meta_tags(page))
          .to include('<meta property="og:image:height" content="200">')
      end

      it "renders the image type" do
        expect(helper.pages_meta_tags(page))
          .to include('<meta property="og:image:type" content="image/png">')
      end

      it "does not render the alternative text when it is blank" do
        expect(helper.pages_meta_tags(page)).not_to include("og:image:alt")
      end

      it "renders the resized image URL" do
        expect(helper.pages_meta_tags(page))
          .to include(%(<meta property="og:image" content="#{
            helper.meta_image_url(image)}">))
      end
    end

    context "with an image with alternative text" do
      let(:image) { create(:image, alternative: "A blue square") }
      let(:page) { create(:page, meta_image: image) }

      it "renders the alternative text" do
        expect(helper.pages_meta_tags(page))
          .to include('<meta property="og:image:alt" content="A blue square">')
      end
    end

    context "without an image" do
      let(:page) { create(:page) }

      it "does not render image dimensions" do
        expect(helper.pages_meta_tags(page)).not_to include("og:image")
      end
    end

    context "with a meta image URL string" do
      before { helper.content_for(:meta_image, "http://example.com/foo.png") }

      it "renders the image" do
        expect(helper.pages_meta_tags).to include(
          '<meta property="og:image" content="http://example.com/foo.png">'
        )
      end

      it "does not render image dimensions" do
        expect(helper.pages_meta_tags).not_to include("og:image:width")
      end

      it "does not render the image type" do
        expect(helper.pages_meta_tags).not_to include("og:image:type")
      end
    end
  end

  describe "#meta_image_size" do
    it "returns nil for a string" do
      expect(helper.meta_image_size("http://example.com/foo.png")).to be_nil
    end

    it "returns the fitted size of an image" do
      expect(helper.meta_image_size(create(:image)))
        .to eq(Vector2d.new(320, 200))
    end

    it "fits the image to the given size" do
      expect(helper.meta_image_size(create(:image), size: "100x"))
        .to eq(Vector2d.new(100, 62))
    end
  end
end
