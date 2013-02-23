require 'spec_helper'

describe Localization do

  let(:localization) { create(:localization) }

  it { should belong_to(:localizable) }

  describe ".locales" do
    before do
      create(:localization, locale: 'en')
      create(:localization, locale: 'nb')
    end
    subject { Localization.locales }
    it { should =~ ['en', 'nb'] }
  end

  describe ".names" do
    before do
      create(:localization, name: 'title')
      create(:localization, name: 'body')
    end
    subject { Localization.names }
    it { should =~ ['title', 'body'] }
  end

  describe "#to_s" do
    subject { localization.to_s }

    context "when value is nil" do
      let(:localization) { create(:localization, value: nil) }
      it { should == "" }
    end

    context "when value is set" do
      let(:localization) { create(:localization, value: "Hello world") }
      it { should == "Hello world" }
    end
  end

  describe "#to_html" do
    let(:localization) { create(:localization, value: "Hello world") }

    context "with no options" do
      subject { localization.to_html }
      it { should == "<p>Hello world</p>" }
    end

    context "with :shorten" do
      subject { localization.to_html(shorten: 4) }
      it { should == "<p>Hello&#8230;</p>" }
    end
  end

  describe "#to_html_with" do
    let(:localization) { create(:localization, value: "Hello world") }

    context "with no options" do
      subject { localization.to_html_with('again') }
      it { should == "<p>Hello world again</p>" }
    end

    context "with :shorten" do
      subject { localization.to_html_with('Read more', shorten: 4) }
      it { should == "<p>Hello&#8230; Read more</p>" }
    end
  end

  describe "#empty?" do
    subject { localization.empty? }

    context "when value is empty" do
      let(:localization) { create(:localization, value: nil) }
      it { should be_true }
    end

    context "when value is blank" do
      let(:localization) { create(:localization, value: "") }
      it { should be_true }
    end

    context "when value is set" do
      let(:localization) { create(:localization, value: "Hello world") }
      it { should be_false }
    end
  end

  describe "#translate" do
    before do
      create(:localization,
        locale: 'fr',
        localizable: localization.localizable,
        value: "Bonjour tout le monde"
      )
    end
    specify { localization.translate('fr').to_s.should == "Bonjour tout le monde" }
    specify { localization.translate('en').to_s.should_not == "Bonjour tout le monde" }
  end

end