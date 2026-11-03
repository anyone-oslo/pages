# frozen_string_literal: true

require "rails_helper"

describe PagesCore::HtmlFormatter do
  subject(:html) { described_class.new(string, options).to_html }

  let(:string) { "Hello world" }
  let(:options) { {} }

  def attachment_path(attachment)
    Rails.application.routes.url_helpers.attachment_path(
      attachment.digest,
      attachment,
      format: attachment.filename_extension
    )
  end

  describe ".to_html" do
    specify do
      expect(described_class.to_html("Test")).to eq("<p>Test</p>")
    end
  end

  describe "#to_html" do
    it { is_expected.to eq("<p>Hello world</p>") }

    it "emits a HTML safe string" do
      expect(html.html_safe?).to be(true)
    end

    context "with unclosed tags" do
      let(:string) { "<i>Unclosed" }

      it { is_expected.to eq("<p><i>Unclosed</i></p>") }
    end

    context "with line breaks" do
      let(:string) { "Hello\nworld" }

      it { is_expected.to eq("<p>Hello<br>\nworld</p>") }
    end

    describe "with :shorten" do
      let(:options) { { shorten: 4 } }

      it { is_expected.to eq("<p>Hello…</p>") }
    end

    describe "with :append" do
      let(:options) { { append: "again" } }

      it { is_expected.to eq("<p>Hello world again</p>") }
    end

    describe "with :shorten and :append" do
      let(:options) { { shorten: 4, append: "again" } }

      it { is_expected.to eq("<p>Hello… again</p>") }
    end
  end

  describe "attaching embeds" do
    let(:page_file) { create(:page_file) }

    context "with attachment" do
      let(:attachment) { page_file.attachment }
      let(:string) { "Download [attachment:#{attachment.id}]" }

      it "embeds a link to the file" do
        expect(html).to(
          match("<p>Download <a class=\"file\" href=\"" \
                "#{attachment_path(attachment)}\">#{attachment.name}</a></p>")
        )
      end
    end

    context "with file" do
      let(:string) { "Download [file:#{page_file.id}]" }

      it "embeds a link to the file" do
        expect(html).to match(
          "<p>Download <a class=\"file\" href=\"" \
          "#{attachment_path(page_file.attachment)}\">" \
          "#{page_file.attachment.name}</a></p>"
        )
      end
    end

    context "when attachment name has inline formatting" do
      let(:attachment) do
        create(:attachment, name: "_Report_ 2019 - 2020")
      end
      let(:string) { "Download [attachment:#{attachment.id}]" }

      it "formats the name" do
        expect(html).to include("><em>Report</em> 2019 – 2020</a>")
      end
    end

    context "when attachment name has a linked image" do
      let(:attachment) do
        create(:attachment,
               name: "!{position:fixed}x.png!:https://example.com Report")
      end
      let(:string) { "Download [attachment:#{attachment.id}]" }

      it "renders a single link to the file" do
        expect(html).to eq(
          "<p>Download <a class=\"file\" " \
          "href=\"#{attachment_path(attachment)}\"> Report</a></p>"
        )
      end
    end

    context "when attachment name has textile link syntax" do
      let(:attachment) { create(:attachment, name: '"x":https://example.com') }
      let(:string) { "Download [attachment:#{attachment.id}]" }

      it "renders the name as text" do
        expect(html).to eq(
          "<p>Download <a class=\"file\" " \
          "href=\"#{attachment_path(attachment)}\">" \
          "\"x\":https://example.com</a></p>"
        )
      end
    end

    context "with several files" do
      let(:second_file) { create(:page_file, page: page_file.page) }
      let(:string) { "Download [file:#{page_file.id},#{second_file.id}]" }

      let(:output) do
        "<p>Download <a class=\"file\" href=\"" \
          "#{attachment_path(page_file.attachment)}\">" \
          "#{page_file.attachment.name}</a>, <a class=\"file\" " \
          "href=\"#{attachment_path(second_file.attachment)}\">" \
          "#{second_file.attachment.name}</a></p>"
      end

      it "embeds links to the files" do
        expect(html).to(match(output))
      end
    end
  end

  describe "embedding images" do
    let(:uploaded_file) do
      Rack::Test::UploadedFile.new(
        File.open(File.expand_path("../../support/fixtures/image.png",
                                   __dir__)),
        "image/png"
      )
    end
    let(:image) { Image.create(file: uploaded_file) }

    context "with image without attributes" do
      let(:string) { "[image:#{image.id}]" }

      it "renders a picture inside a figure" do
        expect(html)
          .to start_with(%(<figure class="image landscape"><picture>) +
                         %(<source type="image/webp" srcset="))
      end

      it "offers a webp candidate" do
        expect(html).to match(%r{/320x200/#{image.id}-\w+\.webp 320w"})
      end

      it "falls back to the stored format" do
        expect(html)
          .to end_with(
            %(/320x200/#{image.to_param}.png" width="320" height="200">) \
            "</picture></figure>"
          )
      end
    end

    context "when image has no alternative text" do
      let(:string) { "[image:#{image.id}]" }

      it "omits the alt attribute" do
        expect(html).not_to include("alt=")
      end
    end

    context "when image has alternative text" do
      let(:image) do
        Image.create(file: uploaded_file, alternative: "A blue square",
                     locale: I18n.locale)
      end
      let(:string) { "[image:#{image.id}]" }

      it "renders the alternative text as alt" do
        expect(html).to include(%(<img alt="A blue square" src=))
      end
    end

    context "when image is decorative" do
      let(:image) { Image.create(file: uploaded_file, decorative: true) }
      let(:string) { "[image:#{image.id}]" }

      it "renders an empty alt" do
        expect(html).to include(%(<img alt="" src=))
      end
    end

    context "with a legacy size attribute" do
      let(:string) { "[image:#{image.id} size=\"100x100\"]" }

      it "ignores it and renders the responsive image" do
        expect(html).to include("<picture>")
      end

      it "does not render at the requested size" do
        expect(html).not_to include("100x62")
      end
    end

    context "with image with class name" do
      let(:string) { "[image:#{image.id} class=\"float-left\"]" }

      it "adds the class to the figure" do
        expect(html)
          .to start_with(%(<figure class="image landscape float-left">))
      end
    end

    context "with image with link" do
      let(:string) { "[image:#{image.id} link=\"http://example.com\"]" }

      it "wraps the picture in a link" do
        expect(html)
          .to start_with(%(<figure class="image landscape">) +
                         %(<a href="http://example.com"><picture>))
      end
    end

    context "with non-existant image" do
      let(:string) { "[image:31337]" }

      it { is_expected.to eq("") }
    end

    context "when image has a caption" do
      let(:image) do
        Image.create(
          file: uploaded_file,
          caption: "This is a caption",
          locale: I18n.locale
        )
      end
      let(:string) { "[image:#{image.id}]" }

      it "renders the caption after the picture" do
        expect(html)
          .to end_with("</picture><figcaption>This is a caption" \
                       "</figcaption></figure>")
      end
    end

    context "when caption has italics" do
      let(:image) do
        Image.create(file: uploaded_file, caption: "_Fra havet_, 2019",
                     locale: I18n.locale)
      end
      let(:string) { "[image:#{image.id}]" }

      it "renders the italics" do
        expect(html).to end_with("<figcaption><em>Fra havet</em>, 2019" \
                                 "</figcaption></figure>")
      end
    end

    context "when caption has line breaks" do
      let(:image) do
        Image.create(file: uploaded_file, caption: "Line one\nLine two",
                     locale: I18n.locale)
      end
      let(:string) { "[image:#{image.id}]" }

      it "renders the line breaks" do
        expect(html).to end_with("<figcaption>Line one<br>\nLine two" \
                                 "</figcaption></figure>")
      end
    end

    context "when caption has a linked image" do
      let(:image) do
        Image.create(
          file: uploaded_file,
          caption: "!{position:fixed}x.png!:https://example.com Caption",
          locale: I18n.locale
        )
      end
      let(:string) { "[image:#{image.id}]" }

      it "renders only the text" do
        expect(html).to end_with("<figcaption> Caption</figcaption></figure>")
      end
    end

    context "when caption has textile link syntax" do
      let(:image) do
        Image.create(file: uploaded_file, caption: '"x":https://example.com',
                     locale: I18n.locale)
      end
      let(:string) { "[image:#{image.id}]" }

      it "renders the caption as text" do
        expect(html).to end_with(
          "<figcaption>\"x\":https://example.com</figcaption></figure>"
        )
      end
    end

    context "when caption contains textile block markup" do
      let(:image) do
        Image.create(file: uploaded_file, caption: "h1. Caption",
                     locale: I18n.locale)
      end
      let(:string) { "[image:#{image.id}]" }

      it "renders it as text" do
        expect(html).to end_with("<figcaption>h1. Caption" \
                                 "</figcaption></figure>")
      end
    end
  end
end
