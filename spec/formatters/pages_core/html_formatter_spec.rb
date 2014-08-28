# encoding: utf-8

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
    let(:imagefile) { File.open(File.expand_path("../../../support/fixtures/image.png", __FILE__)) }
    let(:image) { Image.create(imagefile: imagefile) }

    subject { PagesCore::HtmlFormatter.new(string, options).to_html }

    it { should == "<p>Hello world</p>" }
    its(:html_safe?) { should be_true }

    context "with image" do
      context "without attributes" do
        let(:string) { "[image:#{image.id}]" }
        it { should match(/<p><img alt=\"image\" height=\"200\" src=\"\/dynamic_image\/#{image.id}\/320x200\/image-([\w\d]+).png\" width=\"320\" \/><\/p>/) }
      end

      context "with size" do
        let(:string) { "[image:#{image.id} size=\"100x100\"]" }
        it { should match(/<p><img alt=\"image\" height=\"63\" src=\"\/dynamic_image\/#{image.id}\/100x63\/image-([\w\d]+).png\" width=\"100\" \/><\/p>/) }
      end

      context "with class name" do
        let(:string) { "[image:#{image.id} class=\"float-left\"]" }
        it { should match(/<p><img alt=\"image\" class=\"float-left\" height=\"200\" src=\"\/dynamic_image\/#{image.id}\/320x200\/image-([\w\d]+).png\" width=\"320\" \/><\/p>/) }
      end

      context "with non-existant image" do
        let(:string) { "[image:31337]" }
        it { should == "" }
      end
    end

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