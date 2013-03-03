require 'spec_helper'

describe PagesCore::StringExtensions do
  let(:string) { "Hello world" }

  subject { string }

  it { should be_a(PagesCore::StringExtensions) }

  describe "#to_html" do

    context "with no options" do
      subject { string.to_html }
      it { should == "<p>Hello world</p>" }
    end

    context "with :shorten" do
      subject { string.to_html(shorten: 4) }
      it { should == "<p>Hello&#8230;</p>" }
    end
  end

  describe "#to_html_with" do

    context "with no options" do
      subject { string.to_html_with('again') }
      it { should == "<p>Hello world again</p>" }
    end

    context "with :shorten" do
      subject { string.to_html_with('Read more', shorten: 4) }
      it { should == "<p>Hello&#8230; Read more</p>" }
    end
  end

end