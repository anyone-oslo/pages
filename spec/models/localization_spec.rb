# encoding: utf-8

require 'spec_helper'

describe Localization do

  let(:localization) { create(:localization) }

  it { is_expected.to belong_to(:localizable) }

  describe ".locales" do
    before do
      create(:localization, locale: 'en')
      create(:localization, locale: 'nb')
    end
    subject { Localization.locales }
    it { is_expected.to match(['en', 'nb']) }
  end

  describe ".names" do
    before do
      create(:localization, name: 'title')
      create(:localization, name: 'body')
    end
    subject { Localization.names }
    it { is_expected.to match(['title', 'body']) }
  end

  describe "#to_s" do
    subject { localization.to_s }

    context "when value is nil" do
      let(:localization) { create(:localization, value: nil) }
      it { is_expected.to eq("") }
    end

    context "when value is set" do
      let(:localization) { create(:localization, value: "Hello world") }
      it { is_expected.to eq("Hello world") }
    end
  end

  describe "#empty?" do
    subject { localization.empty? }

    context "when value is empty" do
      let(:localization) { create(:localization, value: nil) }
      it { is_expected.to eq(true) }
    end

    context "when value is blank" do
      let(:localization) { create(:localization, value: "") }
      it { is_expected.to eq(true) }
    end

    context "when value is set" do
      let(:localization) { create(:localization, value: "Hello world") }
      it { is_expected.to eq(false) }
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
    specify { expect(localization.translate('fr').to_s).to eq("Bonjour tout le monde") }
    specify { expect(localization.translate('en').to_s).not_to eq("Bonjour tout le monde") }
  end

end