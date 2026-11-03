# frozen_string_literal: true

require "rails_helper"

describe Attachment do
  let(:png) { Rails.root.join("../support/fixtures/image.png").binread }

  describe "content type" do
    subject { create(:attachment, file:).content_type }

    context "when the declared type matches the data" do
      let(:file) { uploaded_file(png, "image.png", "image/png") }

      it { is_expected.to eq("image/png") }
    end

    context "when HTML is declared as an image" do
      let(:file) do
        uploaded_file("<!DOCTYPE html><html><body></body></html>",
                      "image.png", "image/png")
      end

      it { is_expected.to eq("text/html") }
    end

    context "when an image is declared as HTML" do
      let(:file) { uploaded_file(png, "image.png", "text/html") }

      it { is_expected.to eq("image/png") }
    end

    context "when the data is unrecognized" do
      let(:file) { uploaded_file("<b>hi</b>", "page.html", "image/png") }

      it { is_expected.to eq("text/html") }
    end

    context "when nothing identifies the type" do
      let(:file) { uploaded_file("\x00\x01", "data", "image/png") }

      it { is_expected.to eq("application/octet-stream") }
    end
  end

  describe "#inline?" do
    subject { build(:attachment, filename:, content_type:).inline? }

    { "a.png" => "image/png", "a.jpg" => "image/jpeg", "a.gif" => "image/gif",
      "a.webp" => "image/webp", "a.pdf" => "application/pdf",
      "a.mp3" => "audio/mpeg", "a.mp4" => "video/mp4" }.each do |name, type|
      context "with #{name} as #{type}" do
        let(:filename) { name }
        let(:content_type) { type }

        it { is_expected.to be(true) }
      end
    end

    { "a.html" => "text/html", "a.svg" => "image/svg+xml",
      "a.xml" => "application/xml", "a.js" => "text/javascript",
      "a" => "application/octet-stream", "b.html" => "image/png",
      "a.png" => "image/jpeg", "a.jpg" => "image/jpg" }.each do |name, type|
      context "with #{name} as #{type}" do
        let(:filename) { name }
        let(:content_type) { type }

        it { is_expected.to be(false) }
      end
    end
  end

  describe "a PNG uploaded as x.html" do
    subject(:attachment) do
      create(:attachment, file: uploaded_file(png, "x.html", "text/html"))
    end

    it "detects the content type from the data" do
      expect(attachment.content_type).to eq("image/png")
    end

    it { is_expected.not_to be_inline }
  end
end
