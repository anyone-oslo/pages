# frozen_string_literal: true

require "rails_helper"

describe "feeds/pages" do
  let(:items) { [] }
  let(:feed) { Nokogiri::XML(rendered) }
  let(:page) do
    create(:page, page_images_attributes: [{ image_id: image.id, primary: true }])
  end

  def uploaded_file(name, content_type)
    Rack::Test::UploadedFile.new(
      File.expand_path("../../support/fixtures/#{name}", __dir__),
      content_type
    )
  end

  before do
    assign(:items, items)
    without_partial_double_verification do
      allow(view).to receive(:root_url).and_return("http://test.host/")
    end
    render template: "feeds/pages", formats: [:rss]
  end

  it "renders the language as an element" do
    expect(rendered).to include("<language>#{I18n.locale}</language>")
  end

  describe "media:description" do
    subject(:descriptions) do
      feed.xpath("//item/media:content/media:description",
                 "media" => "http://search.yahoo.com/mrss/")
    end

    let(:items) { [page] }

    context "when the image has alternative text" do
      let(:image) do
        create(:image, alternative: "A blue square",
                       locale: I18n.default_locale)
      end

      it { is_expected.to contain_exactly(have_attributes(text: "A blue square")) }
    end

    context "when the image is decorative" do
      let(:image) do
        create(:image, decorative: true, locale: I18n.default_locale)
      end

      it { is_expected.to contain_exactly(have_attributes(text: "")) }
    end

    context "when a decorative image has alternative text" do
      let(:image) do
        create(:image, decorative: true, alternative: "A blue square",
                       locale: I18n.default_locale)
      end

      it { is_expected.to contain_exactly(have_attributes(text: "")) }
    end

    context "when the image has no alternative text" do
      let(:image) { create(:image, locale: I18n.default_locale) }

      it { is_expected.to be_empty }
    end
  end

  context "with an image" do
    let(:image) do
      create(:image, file: uploaded_file("large_image.png", "image/png"))
    end
    let(:items) { [page] }

    describe "media:content" do
      subject(:content) { feed.at_xpath("//media:content") }

      it "links the resized image" do
        expect(content["url"]).to include("/1200x800/")
      end

      it "renders the fitted width" do
        expect(content["width"]).to eq("1200")
      end

      it "renders the fitted height" do
        expect(content["height"]).to eq("800")
      end

      it "does not render a file size" do
        expect(content["fileSize"]).to be_nil
      end

      it "renders the type" do
        expect(content["type"]).to eq("image/png")
      end
    end

    describe "enclosure" do
      subject(:enclosure) { feed.at_xpath("//enclosure") }

      it "links the resized image" do
        expect(enclosure["url"]).to include("/1200x800/")
      end

      it "renders a zero length" do
        expect(enclosure["length"]).to eq("0")
      end

      it "renders the type" do
        expect(enclosure["type"]).to eq("image/png")
      end
    end
  end

  context "with a WebP image" do
    let(:image) do
      create(:image, file: uploaded_file("image.webp", "image/webp"))
    end
    let(:items) { [page] }

    it "serves the image as JPEG" do
      expect(feed.at_xpath("//enclosure")["url"]).to end_with(".jpeg")
    end

    it "renders the JPEG type" do
      expect(feed.at_xpath("//enclosure")["type"]).to eq("image/jpeg")
    end
  end

  context "with a transparent WebP image" do
    let(:image) do
      create(:image, file: uploaded_file("transparent.webp", "image/webp"))
    end
    let(:items) { [page] }

    it "serves the image as PNG" do
      expect(feed.at_xpath("//enclosure")["url"]).to end_with(".png")
    end

    it "renders the PNG type" do
      expect(feed.at_xpath("//enclosure")["type"]).to eq("image/png")
    end
  end
end
