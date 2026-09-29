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

  context "with legacy file codes" do
    let(:page) { create(:page) }
    let(:files) do
      create_list(:attachment, 2)
      create_list(:page_file, 2, page:)
    end
    let(:text) { "Get [file:#{files.first.id}] and [file:#{files.map(&:id).join(',')}]" }

    it "points them at the file's attachment" do
      expect(result[:html]).to eq(
        "<p>Get [attachment:#{files.first.attachment_id}] and " \
        "[attachment:#{files.map(&:attachment_id).join(',')}]</p>"
      )
    end

    it "uses different ids than the page files" do
      expect(files.map(&:attachment_id)).not_to eq(files.map(&:id))
    end
  end

  context "with a file code for a missing file" do
    let(:text) { "Get [file:999999]" }

    it "keeps the code" do
      expect(result[:html]).to eq("<p>Get [file:999999]</p>")
    end

    it "reports it" do
      expect(result[:removed]).to eq(["file code #999999 (file not found)"])
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
      expect(result[:removed]).to eq(["image from another website", "centred text"])
    end
  end

  context "with div and span" do
    let(:text) { "<div>a</div>\n\n<p>b <span>c</span></p>" }

    it "reports them, since the editor has no node for them" do
      expect(result[:removed]).to eq(["other formatting (<div>)", "other formatting (<span>)"])
    end
  end

  describe "kept tags" do
    it "lists the tags the document editor keeps" do
      expect(described_class::KEPT_TAGS[:document]).to eq(
        %w[p br a strong em s u sup h2 h3 h4 ul ol li blockquote hr
           aside figure iframe]
      )
    end

    it "lists the tags the inline editor keeps" do
      expect(described_class::KEPT_TAGS[:inline]).to eq(
        %w[p br a strong em sup]
      )
    end
  end

  context "with an inline block" do
    subject(:result) { described_class.convert(text, format: "inline") }

    let(:text) do
      "h2. Title\n\n* item\n\n" \
        "<table><tr><td>x</td></tr></table>\n\n" \
        "<iframe src=\"https://www.youtube.com/embed/x\"></iframe>"
    end

    it "keeps no raw blocks" do
      expect(result[:raw]).to eq([])
    end

    it "reports what is flattened" do
      expect(result[:removed]).to eq(%w[headings lists tables embeds])
    end
  end
end
