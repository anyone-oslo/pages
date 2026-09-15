# frozen_string_literal: true

require "rails_helper"

describe PagesCore::DocumentConverter do
  subject(:result) { described_class.convert(text) }

  let(:text) { "Hello *world*" }

  it "renders Textile" do
    expect(result[:html]).to eq("<p>Hello <strong>world</strong></p>")
  end

  it "reports nothing for supported markup" do
    expect(result).to include(raw: [], removed: [])
  end

  context "with embed codes" do
    let(:text) { "[image:1 class=\"left\"]\n\nSee [attachment:2] (pdf)" }

    it "unwraps image-only paragraphs" do
      expect(result[:html]).to start_with("[image:1 class=\"left\"]")
    end

    it "keeps attachment codes inline" do
      expect(result[:html]).to include("<p>See [attachment:2] (pdf)</p>")
    end
  end

  context "with RedCloth artifacts" do
    let(:text) { "h1. NASA title\n\n-gone- +new+" }

    it "folds headings and renames marks" do
      expect(result[:html]).to eq(
        "<h2>NASA title</h2>\n<p><s>gone</s> <u>new</u></p>"
      )
    end
  end

  context "with a video iframe" do
    let(:text) { "<iframe src=\"https://www.youtube.com/embed/x\"></iframe>" }

    it { expect(result[:raw]).to eq([]) }
  end

  context "with unsupported markup" do
    let(:text) do
      "<iframe src=\"https://www.ustream.tv/embed/1\"></iframe>\n\n" \
        "<script>a()</script>\n<script>b()</script>\n\n" \
        "<form><input type=\"text\"></form>\n\n" \
        "<img src=\"https://x/y.png\">\n\n<center>midt</center>"
    end

    it "reports what becomes raw blocks" do
      expect(result[:raw]).to eq(["embed from www.ustream.tv", "2 × script", "form"])
    end

    it "reports what is flattened" do
      expect(result[:removed]).to eq(["image from another website", "<center>"])
    end
  end
end
