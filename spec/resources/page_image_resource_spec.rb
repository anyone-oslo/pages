# frozen_string_literal: true

require "rails_helper"

RSpec.describe PageImageResource do
  subject(:serialized) { described_class.new(page_image).to_h }

  let(:image) do
    create(:image, alternative: "A blue square", caption: "Kittens", locale: "en")
  end
  let(:page_image) do
    PageImage.create!(page: create(:page), image:, primary: true, locale: "en")
  end

  def image_path(record, size)
    key = ["show", record.id, size].compact.join("-")
    digest = DynamicImage.digest_verifier.generate(key)
    "/dynamic_images/#{digest}/#{size}/#{record.to_param}.png"
  end

  it "serializes the page image id" do
    expect(serialized["id"]).to eq(page_image.id)
  end

  it "serializes the image id" do
    expect(serialized["image_id"]).to eq(image.id)
  end

  it "serializes the primary flag" do
    expect(serialized["primary"]).to be(true)
  end

  it "serializes the localized alternative text" do
    expect(serialized["alternative"]).to eq("A blue square")
  end

  it "serializes the localized caption" do
    expect(serialized["caption"]).to eq("Kittens")
  end

  it "serializes the filename" do
    expect(serialized["filename"]).to eq("image.png")
  end

  it "serializes the creation time of the image" do
    expect(serialized["created_at"]).to eq(image.created_at)
  end

  it "serializes a signed url fitted to 2000x2000" do
    expect(serialized["url"]).to eq(image_path(image, "320x200"))
  end

  it "emits exactly these keys" do
    expect(serialized.keys)
      .to eq(%w[id image_id primary alternative caption filename created_at url])
  end

  describe "#serialize" do
    subject(:json) { JSON.parse(described_class.new(page_image).serialize) }

    it "renders the url" do
      expect(json["url"]).to eq(image_path(image, "320x200"))
    end

    it "renders the creation time as a string" do
      expect(json["created_at"]).to eq(image.created_at.to_s)
    end
  end

  context "when the page image locale differs from the image locale" do
    let(:page_image) do
      PageImage.create!(page: create(:page), image:, primary: false, locale: "nb")
    end

    it "serializes a blank alternative text" do
      expect(serialized["alternative"]).to eq("")
    end

    it "serializes a blank caption" do
      expect(serialized["caption"]).to eq("")
    end
  end

  context "when the page image has no locale" do
    let(:page_image) do
      PageImage.create!(page: create(:page), image:, primary: false)
    end

    it "serializes a blank alternative text" do
      expect(serialized["alternative"]).to eq("")
    end
  end
end
