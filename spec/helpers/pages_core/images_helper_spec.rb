# frozen_string_literal: true

require "rails_helper"

RSpec.describe PagesCore::ImagesHelper do
  let(:image) { create(:image) }
  let(:large_image) do
    create(:image, file: uploaded_file("large_image.png", "image/png"))
  end
  let(:candidates) do
    [["390x260", 390], ["550x366", 550], ["780x520", 780],
     ["1090x726", 1090], ["1530x1020", 1530], ["2140x1426", 2140],
     ["3000x2000", 3000]]
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

  def picture_markup(record, candidates, src_size,
                     sizes: "100vw", fallback: "png")
    set = srcset(record, candidates, format: "webp")
    source = %(<source type="image/webp" srcset="#{set}" sizes="#{sizes}">)
    "<picture>#{source}#{img_tag(record, src_size, format: fallback)}</picture>"
  end

  describe "#image_figure" do
    it "renders a picture inside a figure" do
      expect(helper.image_figure(large_image))
        .to eq(figure(picture_markup(large_image, candidates, "1200x800")))
    end

    it "renders the full candidate width ladder" do
      expect(srcset_widths(helper.image_figure(large_image)))
        .to eq([390, 550, 780, 1090, 1530, 2140, 3000])
    end

    it "offers a single candidate for an image smaller than the range" do
      expect(srcset_widths(helper.image_figure(image))).to eq([320])
    end

    it "does not upscale the fallback past the image" do
      expect(helper.image_figure(image))
        .to include(image_path(image, "320x200"))
    end

    it "omits the caption when the record has none" do
      expect(helper.image_figure(image)).not_to include("figcaption")
    end

    context "when the record has a caption" do
      let(:image) { create(:image, caption: "Kittens", locale: I18n.locale) }

      it "renders the caption from the record" do
        expect(helper.image_figure(image))
          .to end_with("</picture><figcaption>Kittens</figcaption></figure>")
      end

      it "overrides the caption with :caption" do
        expect(helper.image_figure(image, caption: "Puppies"))
          .to end_with("</picture><figcaption>Puppies</figcaption></figure>")
      end

      it "omits the caption when :caption is false" do
        expect(helper.image_figure(image, caption: false))
          .not_to include("figcaption")
      end
    end

    it "appends :class_name to the figure class list" do
      expect(helper.image_figure(image, class_name: "wide"))
        .to start_with(%(<figure class="image landscape wide">))
    end

    it "wraps the picture in a link when :link is given" do
      expect(helper.image_figure(image, link: "http://example.com"))
        .to start_with(%(<figure class="image landscape">) +
                       %(<a href="http://example.com"><picture>))
    end

    it "sets sizes on the source by default" do
      expect(helper.image_figure(large_image)).to include(%( sizes="100vw">))
    end

    context "with :sizes" do
      it "sets sizes on the source" do
        expect(helper.image_figure(large_image, sizes: "50vw"))
          .to eq(figure(picture_markup(large_image, candidates, "1200x800",
                                       sizes: "50vw")))
      end
    end

    context "with :ratio" do
      let(:candidates) do
        [["390x219", 390], ["550x309", 550], ["780x439", 780],
         ["1090x613", 1090], ["1530x861", 1530], ["2140x1204", 2140],
         ["3000x1688", 3000]]
      end

      it "crops every candidate to the ratio" do
        expect(helper.image_figure(large_image, ratio: 16 / 9r))
          .to eq(figure(picture_markup(large_image, candidates, "1200x675")))
      end
    end

    context "with a still gif" do
      let(:image) { create(:image, file: uploaded_file("image.gif", type)) }
      let(:type) { "image/gif" }

      it "renders a webp source with a gif fallback" do
        expect(helper.image_figure(image))
          .to eq(figure(picture_markup(image, [["320x200", 320]], "320x200",
                                       fallback: "gif")))
      end
    end

    context "with an animated gif" do
      let(:image) do
        create(:image, file: uploaded_file("animated.gif", "image/gif"))
      end
      let(:img) do
        set = srcset(image, [["320x200", 320]], format: "gif")
        img_tag(image, "320x200", format: "gif",
                                  prefix: %( srcset="#{set}" sizes="100vw"))
      end

      it "keeps the gif format and moves the srcset onto the img" do
        expect(helper.image_figure(image))
          .to eq(figure("<picture>#{img}</picture>"))
      end
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
    it "renders the same markup as #image_figure" do
      expect(helper.picture(large_image))
        .to eq(helper.image_figure(large_image))
    end

    it "passes its options on" do
      expect(helper.picture(image, class_name: "wide", caption: "Kittens"))
        .to eq(helper.image_figure(image, class_name: "wide",
                                          caption: "Kittens"))
    end
  end

  describe "the deprecated srcset helpers" do
    describe "#image_size" do
      it "returns a width-only size without a ratio" do
        expect(helper.image_size(700, nil)).to eq("700x")
      end

      it "derives the height from a ratio" do
        expect(helper.image_size(700, 16 / 9r)).to eq("700x394")
      end
    end

    describe "#image_widths" do
      it "omits widths the image cannot supply" do
        expect(helper.image_widths(image)).to eq([233])
      end

      it "returns the full ladder for a large image" do
        expect(helper.image_widths(large_image))
          .to eq([233, 350, 700, 1050, 1400, 2100, 2800])
      end
    end

    describe "#srcset" do
      it "builds a srcset from the old ladder" do
        expect(helper.srcset(image))
          .to eq("#{image_path(image, '233x145')} 233w")
      end

      it "renders the requested format" do
        expect(helper.srcset(image, format: :webp))
          .to eq("#{image_path(image, '233x145', format: 'webp')} 233w")
      end
    end

    describe "#webp_compatible?" do
      let(:gif) do
        create(:image, file: uploaded_file("image.gif", "image/gif"))
      end

      it "is true for a png" do
        expect(helper).to be_webp_compatible(image)
      end

      it "is false for a gif" do
        expect(helper).not_to be_webp_compatible(gif)
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
