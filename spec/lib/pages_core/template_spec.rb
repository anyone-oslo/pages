require "rails_helper"

class ApplicationTemplate < PagesCore::Template
  block :video_embed, size: :large
end

class IndexTemplate < ApplicationTemplate
  filename "default"
  name "Default"
  images true
  enabled_blocks []
end

class InheritedTemplate < IndexTemplate; end

class NewsItemTemplate < ApplicationTemplate
  enabled_blocks :headline, :name, :excerpt, :body, :video_embed
end

describe PagesCore::Template do
  let(:template_class) { ApplicationTemplate }
  let(:template) { template_class.new }

  describe "#block_names" do
    subject { template.block_names }

    context "with default configuration" do
      it { is_expected.to eq([:name, :headline, :excerpt, :body]) }
    end

    context "with configuration set" do
      let(:template_class) { NewsItemTemplate }
      it "should return the template names" do
        expect(subject).to eq([:headline, :name, :excerpt, :body, :video_embed])
      end
    end

    context "with inherited configuration" do
      let(:template_class) { InheritedTemplate }
      it { is_expected.to eq([:name]) }
    end
  end

  describe "#blocks" do
    let(:expected_blocks) do
      {
        name: { size: :field },
        headline: { size: :field },
        excerpt: {},
        body: { size: :large }
      }
    end

    subject { template.blocks }

    context "with default configuration" do
      it { is_expected.to eq(expected_blocks) }
    end

    context "with configuration set" do
      let(:template_class) { NewsItemTemplate }
      let(:expected_blocks) do
        {
          headline: { size: :field },
          name: { size: :field },
          excerpt: {},
          body: { size: :large },
          video_embed: { size: :large }
        }
      end
      it { is_expected.to eq(expected_blocks) }
    end
  end

  describe "#filename" do
    subject { template.filename }

    context "with default configuration" do
      let(:template_class) { NewsItemTemplate }
      it { is_expected.to eq("news_item") }
    end

    context "with inherited configuration" do
      let(:template_class) { InheritedTemplate }
      it { is_expected.to eq("default") }
    end
  end

  describe "#id" do
    let(:template_class) { NewsItemTemplate }
    subject { template.id }
    it { is_expected.to eq(:news_item) }
  end

  describe "#path" do
    let(:template_class) { NewsItemTemplate }
    subject { template.path }
    it { is_expected.to eq("pages/templates/news_item") }
  end

  describe "#images?" do
    subject { template.images? }

    it { is_expected.to eq(false) }

    context "with configuration set" do
      let(:template_class) { IndexTemplate }
      it { is_expected.to eq(true) }
    end

    context "with inherited configuration" do
      let(:template_class) { InheritedTemplate }
      it { is_expected.to eq(true) }
    end
  end

  describe "#name" do
    subject { template.name }

    context "with default configuration" do
      let(:template_class) { NewsItemTemplate }
      it { is_expected.to eq("News item") }
    end

    context "with name set" do
      let(:template_class) { IndexTemplate }
      it { is_expected.to eq("Default") }
    end

    context "with inherited configuration" do
      let(:template_class) { InheritedTemplate }
      it { is_expected.to eq("Inherited") }
    end
  end
end
