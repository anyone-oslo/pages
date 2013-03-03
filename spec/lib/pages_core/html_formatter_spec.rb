require 'spec_helper'

describe PagesCore::HtmlFormatter do

  describe ".to_html" do
    specify do
      PagesCore::HtmlFormatter.to_html("Test")
        .should == "<p>Test</p>"
    end
  end

  describe "#to_html" do
    let(:string) { "Hello world" }
    let(:options) { {} }

    subject { PagesCore::HtmlFormatter.new(string, options).to_html }

    it { should == "<p>Hello world</p>" }
    its(:html_safe?) { should be_true }

    context "with line breaks" do
      let(:string) { "Hello\nworld" }
      it { should == "<p>Hello<br />\nworld</p>" }
    end

    describe "with :shorten" do
      let(:options) { {shorten: 4} }
      it { should == "<p>Hello&#8230;</p>" }
    end

    describe "with :append" do
      let(:options) { {append: "again"} }
      it { should == "<p>Hello world again</p>" }
    end

    describe "with :shorten and :append" do
      let(:options) { {shorten: 4, append: "again"} }
      it { should == "<p>Hello&#8230; again</p>" }
    end
  end

end