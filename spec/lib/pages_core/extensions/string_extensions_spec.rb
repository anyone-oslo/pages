require "rails_helper"

describe PagesCore::Extensions::StringExtensions do
  let(:string) { "Hello world" }

  subject { string }

  it { is_expected.to be_a(PagesCore::Extensions::StringExtensions) }

  describe "#to_html" do
    context "with no options" do
      subject { string.to_html }
      it { is_expected.to eq("<p>Hello world</p>") }
    end

    context "with :shorten" do
      subject { string.to_html(shorten: 4) }
      it { is_expected.to eq("<p>Hello&#8230;</p>") }
    end
  end

  describe "#to_html_with" do
    context "with no options" do
      subject { string.to_html_with("again") }
      it { is_expected.to eq("<p>Hello world again</p>") }
    end

    context "with :shorten" do
      subject { string.to_html_with("Read more", shorten: 4) }
      it { is_expected.to eq("<p>Hello&#8230; Read more</p>") }
    end
  end
end
