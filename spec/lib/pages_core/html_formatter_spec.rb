require 'spec_helper'

describe PagesCore::HtmlFormatter do

  describe ".to_html" do
    specify do
      PagesCore::HtmlFormatter.to_html("Test")
        .should == "<p>Test</p>"
    end
  end

  describe "#to_html" do
    it "converts a string to HTML" do
      PagesCore::HtmlFormatter.new("Hello world")
        .to_html
        .should == "<p>Hello world</p>"
    end

    it "converts line breaks to hard breaks" do
      PagesCore::HtmlFormatter.new("Hello\nworld")
        .to_html
        .should == "<p>Hello<br />\nworld</p>"
    end

    it "outputs HTML safe strings" do
      PagesCore::HtmlFormatter.new("Hello world")
        .to_html
        .html_safe?
        .should be_true
    end
  end

end