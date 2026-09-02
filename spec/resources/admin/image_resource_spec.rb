# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::ImageResource do
  subject(:serialized) { described_class.new(image).to_h }

  let(:image) do
    create(:image, alternative: "A blue square", caption: "Kittens", locale: "en")
  end

  def uploaded_file(name, content_type)
    Rack::Test::UploadedFile.new(
      File.expand_path("../../support/fixtures/#{name}", __dir__),
      content_type
    )
  end

  def image_path(record, size, action: nil)
    key = [action || "show", record.id, size].compact.join("-")
    digest = DynamicImage.digest_verifier.generate(key)
    name = action ? "#{record.to_param}/#{action}" : record.to_param
    "/dynamic_images/#{digest}/#{size}/#{name}.png"
  end

  def expected_keys
    %w[id filename content_type content_hash content_length colorspace
       real_width real_height crop_width crop_height crop_start_x
       crop_start_y crop_gravity_x crop_gravity_y created_at updated_at
       alternative caption original_url thumbnail_url cropped_url
       uncropped_url]
  end

  it "emits exactly these keys" do
    expect(serialized.keys).to eq(expected_keys)
  end

  it "serializes the id" do
    expect(serialized["id"]).to eq(image.id)
  end

  it "serializes the filename" do
    expect(serialized["filename"]).to eq("image.png")
  end

  it "serializes the content type" do
    expect(serialized["content_type"]).to eq("image/png")
  end

  it "serializes the content hash" do
    expect(serialized["content_hash"])
      .to eq("9f674106291472e4cb242f21df0a3e0b3dd6f7f1")
  end

  it "serializes the content length" do
    expect(serialized["content_length"]).to eq(1352)
  end

  it "serializes the colorspace" do
    expect(serialized["colorspace"]).to eq("rgb")
  end

  it "serializes the real dimensions" do
    expect(serialized.values_at("real_width", "real_height")).to eq([320, 200])
  end

  it "serializes the crop attributes as nil when the image is uncropped" do
    expect(serialized.values_at("crop_width", "crop_height", "crop_start_x",
                                "crop_start_y", "crop_gravity_x",
                                "crop_gravity_y")).to all(be_nil)
  end

  it "serializes the timestamps" do
    expect(serialized.values_at("created_at", "updated_at"))
      .to eq([image.created_at, image.updated_at])
  end

  describe "localized attributes" do
    before do
      localized = image.localize("nb")
      localized.alternative = "En blå firkant"
      localized.caption = "Kattunger"
      localized.save!
    end

    it "serializes alternative as a hash keyed by locale" do
      expect(serialized["alternative"])
        .to eq({ "en" => "A blue square", "nb" => "En blå firkant" })
    end

    it "serializes caption as a hash keyed by locale" do
      expect(serialized["caption"])
        .to eq({ "en" => "Kittens", "nb" => "Kattunger" })
    end
  end

  it "serializes alternative for a single locale" do
    expect(serialized["alternative"]).to eq({ "en" => "A blue square" })
  end

  it "serializes caption for a single locale" do
    expect(serialized["caption"]).to eq({ "en" => "Kittens" })
  end

  describe "urls" do
    let(:image) do
      create(:image, file: uploaded_file("large_image.png", "image/png"))
    end

    it "points original_url at the unprocessed file" do
      expect(serialized["original_url"])
        .to eq(image_path(image, "3000x2000", action: "original"))
    end

    it "fits thumbnail_url to 500 pixels wide" do
      expect(serialized["thumbnail_url"])
        .to eq(image_path(image, "500x333"))
    end

    it "fits cropped_url within 1200x1200" do
      expect(serialized["cropped_url"])
        .to eq(image_path(image, "1200x800"))
    end

    it "fits uncropped_url within 2000x2000" do
      expect(serialized["uncropped_url"])
        .to eq(image_path(image, "2000x1333", action: "uncropped"))
    end
  end

  describe "with a cropped image" do
    let(:image) do
      create(:image, crop_width: 100, crop_height: 120,
                     crop_start_x: 10, crop_start_y: 20)
    end

    it "serializes the crop attributes" do
      expect(serialized.values_at("crop_width", "crop_height", "crop_start_x",
                                  "crop_start_y")).to eq([100, 120, 10, 20])
    end

    it "sizes cropped_url from the crop" do
      expect(serialized["cropped_url"]).to eq(image_path(image, "100x120"))
    end

    it "sizes uncropped_url from the original" do
      expect(serialized["uncropped_url"])
        .to eq(image_path(image, "320x200", action: "uncropped"))
    end
  end

  describe "#serialize" do
    subject(:json) { JSON.parse(described_class.new(image).serialize) }

    it "renders the localized alternative hash" do
      expect(json["alternative"]).to eq({ "en" => "A blue square" })
    end

    it "renders timestamps as strings" do
      expect(json["created_at"]).to eq(image.created_at.to_s)
    end
  end
end
