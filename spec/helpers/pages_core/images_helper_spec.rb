# frozen_string_literal: true

require "rails_helper"

RSpec.describe PagesCore::ImagesHelper do
  let(:image) { create(:image) }
  let(:large_image) do
    create(:image, file: uploaded_file("large_image.png", "image/png"))
  end
  let(:candidates) do
    [["232x155", 233], ["350x233", 350], ["700x466", 700],
     ["1050x700", 1050], ["1400x933", 1400], ["2100x1400", 2100],
     ["2800x1866", 2800]]
  end

  def uploaded_file(name, content_type)
    Rack::Test::UploadedFile.new(
      File.expand_path("../../support/fixtures/#{name}", __dir__),
      content_type
    )
  end

  def image_path(record, size, action: nil, format: "png")
    key = [action || "show", record.id, size].compact.join("-")
    digest = DynamicImage.digest_verifier.generate(key)
    name = action ? "#{record.to_param}/#{action}" : record.to_param
    "/dynamic_images/#{digest}/#{size}/#{name}.#{format}"
  end

  def img_tag(record, size, prefix: "", action: nil, format: "png")
    width, height = size.split("x")
    path = image_path(record, size, action:, format:)
    %(<img#{prefix} src="#{path}" width="#{width}" height="#{height}" />)
  end

  def figure(content, class_name: "image landscape", caption: nil)
    figcaption = caption ? "<figcaption>#{caption}</figcaption>" : ""
    %(<figure class="#{class_name}">#{content}#{figcaption}</figure>)
  end

  def srcset(record, candidates, format: "png")
    candidates.map do |size, width|
      "#{image_path(record, size, format:)} #{width}w"
    end.join(", ")
  end

  def srcset_widths(markup)
    markup.scan(/(\d+)w/).flatten.map(&:to_i).uniq
  end

  describe "#image_figure" do
    it "renders a figure with the image" do
      expect(helper.image_figure(image))
        .to eq(figure(img_tag(image, "320x200")))
    end

    it "omits the caption when the record has none" do
      expect(helper.image_figure(image)).not_to include("figcaption")
    end

    context "when the record has a caption" do
      let(:image) { create(:image, caption: "Kittens", locale: I18n.locale) }

      it "renders the caption from the record" do
        expect(helper.image_figure(image))
          .to eq(figure(img_tag(image, "320x200"), caption: "Kittens"))
      end

      it "overrides the caption with :caption" do
        expect(helper.image_figure(image, caption: "Puppies"))
          .to eq(figure(img_tag(image, "320x200"), caption: "Puppies"))
      end

      it "omits the caption when :caption is false" do
        expect(helper.image_figure(image, caption: false))
          .to eq(figure(img_tag(image, "320x200")))
      end
    end

    it "appends :class_name to the figure class list" do
      expect(helper.image_figure(image, class_name: "wide"))
        .to eq(figure(img_tag(image, "320x200"),
                      class_name: "image landscape wide"))
    end

    it "wraps the image in a link when :link is given" do
      img = img_tag(image, "320x200")
      expect(helper.image_figure(image, link: "http://example.com"))
        .to eq(figure(%(<a href="http://example.com">#{img}</a>)))
    end

    it "fits the image within 2000x2000 by default" do
      expect(helper.image_figure(image))
        .to include(image_path(image, "320x200"))
    end

    it "fits the image to :size" do
      expect(helper.image_figure(image, size: "100x100"))
        .to eq(figure(img_tag(image, "100x62")))
    end

    it "crops to a float ratio" do
      expect(helper.image_figure(image, ratio: 16.0 / 9.0))
        .to eq(figure(img_tag(image, "320x180")))
    end

    it "crops to a rational ratio" do
      expect(helper.image_figure(image, ratio: 16 / 9r))
        .to eq(figure(img_tag(image, "320x180")))
    end

    it "fits :size to the ratio" do
      expect(helper.image_figure(image, size: "200x200", ratio: 16 / 9r))
        .to eq(figure(img_tag(image, "200x112")))
    end
  end

  describe "orientation class" do
    it "is landscape when the image is wider than it is tall" do
      expect(helper.image_figure(image))
        .to start_with(%(<figure class="image landscape">))
    end

    context "with a portrait image" do
      let(:image) do
        create(:image, crop_width: 100, crop_height: 200,
                       crop_start_x: 0, crop_start_y: 0)
      end

      it "is portrait" do
        expect(helper.image_figure(image))
          .to start_with(%(<figure class="image portrait">))
      end
    end

    context "with a square image" do
      let(:image) do
        create(:image, crop_width: 200, crop_height: 200,
                       crop_start_x: 0, crop_start_y: 0)
      end

      it "is square" do
        expect(helper.image_figure(image))
          .to start_with(%(<figure class="image square">))
      end
    end

    it "is square when a ratio of 1 constrains a landscape image" do
      expect(helper.image_figure(image, ratio: 1))
        .to start_with(%(<figure class="image square">))
    end

    it "is portrait when a portrait ratio constrains a landscape image" do
      expect(helper.image_figure(image, ratio: 9 / 16r))
        .to start_with(%(<figure class="image portrait">))
    end
  end

  describe "#picture" do
    def webp_source(record, candidates, sizes: "100vw")
      set = srcset(record, candidates, format: "webp")
      %(<source type="image/webp" srcset="#{set}" sizes="#{sizes}">)
    end

    def expected_picture(record, candidates, src_size, img_sizes: "")
      source = webp_source(record, candidates)
      prefix = %(#{img_sizes} srcset="#{srcset(record, candidates)}")
      "<picture>#{source}#{img_tag(record, src_size, prefix:)}</picture>"
    end

    it "renders a picture inside a figure" do
      expect(helper.picture(large_image))
        .to eq(figure(expected_picture(large_image, candidates, "1050x700")))
    end

    it "renders the full candidate width ladder" do
      expect(srcset_widths(helper.picture(large_image)))
        .to eq([233, 350, 700, 1050, 1400, 2100, 2800])
    end

    it "omits candidate widths the image cannot supply" do
      expect(srcset_widths(helper.picture(image))).to eq([233])
    end

    it "renders the img at 1050 wide, without upscaling" do
      path = image_path(image, "320x200")
      expect(helper.picture(image)).to include(%(src="#{path}"))
    end

    it "does not set sizes on the img tag by default" do
      expect(helper.picture(large_image)).not_to include("<img sizes=")
    end

    it "sets sizes on the webp source by default" do
      expect(helper.picture(large_image)).to include(%(" sizes="100vw">))
    end

    context "with :sizes" do
      it "sets sizes on the img tag and the webp source" do
        expect(helper.picture(large_image, sizes: "50vw"))
          .to eq(figure(expected_picture_with_sizes))
      end

      def expected_picture_with_sizes
        source = webp_source(large_image, candidates, sizes: "50vw")
        prefix = %( sizes="50vw" srcset="#{srcset(large_image, candidates)}")
        img = img_tag(large_image, "1050x700", prefix:)
        "<picture>#{source}#{img}</picture>"
      end
    end

    context "with :ratio" do
      let(:candidates) do
        [["233x131", 233], ["350x197", 350], ["700x394", 700],
         ["1050x591", 1050], ["1400x788", 1400], ["2100x1181", 2100],
         ["2800x1575", 2800]]
      end

      it "crops every candidate to the ratio" do
        expect(helper.picture(large_image, ratio: 16 / 9r))
          .to eq(figure(expected_picture(large_image, candidates, "1050x591")))
      end
    end

    it "appends :class_name to the figure class list" do
      expect(helper.picture(large_image, class_name: "hero"))
        .to start_with(%(<figure class="image landscape hero">))
    end

    it "wraps the picture in a link when :link is given" do
      expect(helper.picture(large_image, link: "/foo"))
        .to include(%(<figure class="image landscape"><a href="/foo">) \
                    "<picture>")
    end

    it "renders the caption after the picture" do
      expect(helper.picture(large_image, caption: "Kittens"))
        .to end_with("</picture><figcaption>Kittens</figcaption></figure>")
    end

    it "omits the caption when :caption is false" do
      expect(helper.picture(large_image, caption: false))
        .not_to include("figcaption")
    end

    context "with a gif" do
      let(:candidates) { [["233x145", 233]] }
      let(:image) { create(:image, file: uploaded_file("image.gif", type)) }
      let(:type) { "image/gif" }

      it "omits the webp source" do
        set = srcset(image, candidates, format: "gif")
        img = img_tag(image, "320x200",
                      format: "gif", prefix: %( srcset="#{set}"))
        expect(helper.picture(image)).to eq(figure("<picture>#{img}</picture>"))
      end
    end
  end

  describe "#image_caption" do
    context "when the record has a caption" do
      let(:image) { create(:image, caption: "Kittens", locale: I18n.locale) }

      it "renders the caption from the record" do
        expect(helper.image_caption(image))
          .to eq("<figcaption>Kittens</figcaption>")
      end

      it "returns nil when the caption is false" do
        expect(helper.image_caption(image, caption: false)).to be_nil
      end

      it "renders an explicit caption" do
        expect(helper.image_caption(image, caption: "Puppies"))
          .to eq("<figcaption>Puppies</figcaption>")
      end
    end

    it "returns nil when the record has no caption" do
      expect(helper.image_caption(image)).to be_nil
    end

    it "returns nil for a blank explicit caption" do
      expect(helper.image_caption(image, caption: "")).to be_nil
    end

    it "renders an explicit caption for a record without one" do
      expect(helper.image_caption(image, caption: "Puppies"))
        .to eq("<figcaption>Puppies</figcaption>")
    end
  end

  describe "#dynamic_image_tag" do
    it "renders no alt attribute when the record has none" do
      expect(helper.dynamic_image_tag(image)).to eq(img_tag(image, "320x200"))
    end

    it "renders an explicit alt attribute" do
      expect(helper.dynamic_image_tag(image, alt: "Explicit"))
        .to eq(img_tag(image, "320x200", prefix: %( alt="Explicit")))
    end

    context "when the record has alternative text" do
      let(:image) do
        create(:image, alternative: "A blue square", locale: I18n.locale)
      end

      it "renders the alternative text as alt" do
        expect(helper.dynamic_image_tag(image))
          .to eq(img_tag(image, "320x200", prefix: %( alt="A blue square")))
      end

      it "lets an explicit alt option win" do
        expect(helper.dynamic_image_tag(image, alt: "Explicit"))
          .to eq(img_tag(image, "320x200", prefix: %( alt="Explicit")))
      end
    end

    context "when the alternative text is blank" do
      let(:image) { create(:image, alternative: "", locale: I18n.locale) }

      it "renders no alt attribute" do
        expect(helper.dynamic_image_tag(image)).to eq(img_tag(image, "320x200"))
      end
    end
  end

  describe "#uncropped_dynamic_image_tag" do
    context "when the record has alternative text" do
      let(:image) do
        create(:image, alternative: "A blue square", locale: I18n.locale)
      end

      it "renders the alternative text as alt" do
        expect(helper.uncropped_dynamic_image_tag(image, size: "100x100"))
          .to eq(img_tag(image, "100x62", action: "uncropped",
                                          prefix: %( alt="A blue square")))
      end
    end
  end

  describe "#original_dynamic_image_tag" do
    it "raises, as DynamicImage::Helper defines no such method" do
      expect { helper.original_dynamic_image_tag(image) }
        .to raise_error(NoMethodError)
    end
  end
end
