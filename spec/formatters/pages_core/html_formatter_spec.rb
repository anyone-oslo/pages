require "rails_helper"

describe PagesCore::HtmlFormatter do
  describe ".to_html" do
    specify do
      expect(described_class.to_html("Test")).to eq("<p>Test</p>")
    end
  end

  describe "#to_html" do
    subject(:html) { described_class.new(string, options).to_html }

    let(:string) { "Hello world" }
    let(:options) { {} }
    let(:imagefile) do
      File.open(File.expand_path("../../support/fixtures/image.png",
                                 __dir__))
    end
    let(:content_type) { "image/png" }
    let(:uploaded_file) do
      Rack::Test::UploadedFile.new(imagefile, content_type)
    end
    let(:page) { create(:page) }
    let(:page_file) do
      page.page_files.create(file: uploaded_file,
                             name: "Foobar",
                             locale: I18n.locale)
    end
    let(:image) { Image.create(file: uploaded_file) }

    it { is_expected.to eq("<p>Hello world</p>") }

    it "emits a HTML safe string" do
      expect(html.html_safe?).to eq(true)
    end

    context "with file" do
      let(:string) { "Download [file:#{page_file.id}]" }
      let(:expected_path) do
        "/#{I18n.locale}/pages/#{page.id}/files/" \
          "#{page_file.id}-#{page_file.content_hash}.png"
      end

      it "embeds a link to the file" do
        expect(html).to match(
          "<p>Download <a class=\"file\" " \
            "href=\"#{expected_path}\">Foobar</a></p>"
        )
      end
    end

    context "with several files" do
      let(:second_file) do
        page.page_files.create(
          file: uploaded_file,
          name: "Foobar2",
          locale: I18n.locale
        )
      end
      let(:string) { "Download [file:#{page_file.id},#{second_file.id}]" }
      let(:expected_path) do
        "/#{I18n.locale}/pages/#{page.id}/files/" \
          "#{page_file.id}-#{page_file.content_hash}.png"
      end
      let(:expected_path2) do
        "/#{I18n.locale}/pages/#{page.id}/files/" \
          "#{second_file.id}-#{second_file.content_hash}.png"
      end

      it "embeds links to the files" do
        expect(html).to match(
          "<p>Download <a class=\"file\" href=\"#{expected_path}\">Foobar</a>" \
            ", <a class=\"file\" href=\"#{expected_path2}\">Foobar2</a></p>"
        )
      end
    end

    context "with image without attributes" do
      let(:string) { "[image:#{image.id}]" }
      let(:pattern) do
        %r{<figure.class="image.landscape"><img.alt="Image".
        src="/dynamic_images/([\w\d]+)/320x200/#{image.id}-([\w\d]+)\.png"
        .width="320".height="200"./></figure>}x
      end

      it { is_expected.to match(pattern) }
    end

    context "with image with size" do
      let(:string) { "[image:#{image.id} size=\"100x100\"]" }
      let(:pattern) do
        %r{<figure.class="image.landscape"><img.alt="Image".
        src="/dynamic_images/([\w\d]+)/100x62/#{image.id}-([\w\d]+)\.png"
        .width="100".height="62"./></figure>}x
      end

      it { is_expected.to match(pattern) }
    end

    context "with image with class name" do
      let(:string) { "[image:#{image.id} class=\"float-left\"]" }
      let(:pattern) do
        %r{<figure.class="image.landscape.float-left"><img.alt="Image".
        src="/dynamic_images/([\w\d]+)/320x200/#{image.id}-([\w\d]+)\.png"
        .width="320".height="200"./></figure>}x
      end

      it { is_expected.to match(pattern) }
    end

    context "with image with link" do
      let(:string) { "[image:#{image.id} link=\"http://example.com\"]" }
      let(:pattern) do
        %r{<figure.class="image.landscape"><a.href="http://example.com">
        <img.alt="Image".src="/dynamic_images/([\w\d]+)/320x200/#{image.id}
        -([\w\d]+)\.png".width="320".height="200"./></a></figure>}x
      end

      it { is_expected.to match(pattern) }
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
      let(:pattern) do
        %r{<figure.class="image.landscape"><img.alt="Image".
        src="/dynamic_images/([\w\d]+)/320x200/#{image.id}-([\w\d]+)\.png"
        .width="320".height="200"./>
        <figcaption>This.is.a.caption</figcaption></figure>}x
      end

      it { is_expected.to match(pattern) }
    end

    context "with line breaks" do
      let(:string) { "Hello\nworld" }

      it { is_expected.to eq("<p>Hello<br />\nworld</p>") }
    end

    describe "with :shorten" do
      let(:options) { { shorten: 4 } }

      it { is_expected.to eq("<p>Hello&#8230;</p>") }
    end

    describe "with :append" do
      let(:options) { { append: "again" } }

      it { is_expected.to eq("<p>Hello world again</p>") }
    end

    describe "with :shorten and :append" do
      let(:options) { { shorten: 4, append: "again" } }

      it { is_expected.to eq("<p>Hello&#8230; again</p>") }
    end
  end
end
