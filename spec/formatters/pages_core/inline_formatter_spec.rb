# frozen_string_literal: true

require "rails_helper"

describe PagesCore::InlineFormatter do
  subject(:html) { described_class.to_html(string) }

  let(:string) { "Hello world" }

  it { is_expected.to eq("Hello world") }

  it "emits a HTML safe string" do
    expect(html.html_safe?).to be(true)
  end

  context "with nil" do
    let(:string) { nil }

    it { is_expected.to eq("") }
  end

  context "with italics" do
    let(:string) { "_Fra havet_, 2019" }

    it { is_expected.to eq("<em>Fra havet</em>, 2019") }
  end

  context "with bold" do
    let(:string) { "Photo *by* Ola" }

    it { is_expected.to eq("Photo <strong>by</strong> Ola") }
  end

  context "with line breaks" do
    let(:string) { "Line one\nLine two" }

    it { is_expected.to eq("Line one<br>\nLine two") }
  end

  context "with typography" do
    let(:string) { "Oil on canvas - 16x9 (c) Ola" }

    it { is_expected.to eq("Oil on canvas – 16×9 © Ola") }
  end

  context "with paragraphs" do
    let(:string) { "One\n\nTwo" }

    it { is_expected.not_to include("<p>") }
  end

  context "with HTML" do
    let(:string) { "<script>alert(1)</script><b>Bold</b>" }

    it "escapes it" do
      expect(html).to eq("&lt;script&gt;alert(1)&lt;/script&gt;" \
                         "&lt;b&gt;Bold&lt;/b&gt;")
    end
  end

  context "with a link" do
    let(:string) { '"x":https://example.com' }

    it { is_expected.to eq("&quot;x&quot;:https://example.com") }

    it "is not converted by a later Textile pass" do
      expect(RedCloth.new(html).to_html).not_to include("<a")
    end
  end

  context "with a linked image" do
    let(:string) do
      "!{position:fixed;width:100vw}x.png!:https://example.com Caption"
    end

    it { is_expected.to eq(" Caption") }
  end

  context "with styles" do
    let(:string) { "%{color:red}Red%" }

    it { is_expected.to eq("<span>Red</span>") }
  end
end
