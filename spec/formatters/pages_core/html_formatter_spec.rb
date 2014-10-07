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
    let(:content_type) { "image/png" }
    let(:uploaded_file) { Rack::Test::UploadedFile.new(imagefile, content_type) }
    let(:image) { Image.create(file: uploaded_file) }

    subject { PagesCore::HtmlFormatter.new(string, options).to_html }

    it { should == "<p>Hello world</p>" }
    specify { expect(subject.html_safe?).to eq(true) }

    context "with image" do
      context "without attributes" do
        let(:string) { "[image:#{image.id}]" }
        it { should match(/<p><img alt=\"Image\" height=\"200\" src=\"\/dynamic_images\/([\w\d]+)\/320x200\/#{image.id}-([\w\d]+)\.png\" width=\"320\" \/><\/p>/) }
      end

      context "with size" do
        let(:string) { "[image:#{image.id} size=\"100x100\"]" }
        it { should match(/<p><img alt=\"Image\" height=\"62\" src=\"\/dynamic_images\/([\w\d]+)\/100x62\/#{image.id}-([\w\d]+)\.png\" width=\"100\" \/><\/p>/) }
      end

      context "with class name" do
        let(:string) { "[image:#{image.id} class=\"float-left\"]" }
        it { should match(/<p><img alt=\"Image\" class=\"float-left\" height=\"200\" src=\"\/dynamic_images\/([\w\d]+)\/320x200\/#{image.id}-([\w\d]+)\.png\" width=\"320\" \/><\/p>/) }
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