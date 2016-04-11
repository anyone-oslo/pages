require "rails_helper"

describe PagesCore::TemplateBlocks do
  let(:template_class) { ApplicationTemplate }
  let(:template) { template_class.new }

  before { I18n.locale = :en }
  after { I18n.locale = I18n.default_locale }

  describe ".block_ids" do
    subject { PagesCore::Template.block_ids }

    it "should return all block ids" do
      expect(subject).to(
        match_array([:name, :headline, :excerpt, :body, :video_embed])
      )
    end
  end

  describe "#block_description" do
    let(:block) { :excerpt }
    subject { template.block_description(block) }
    it "should localize the description" do
      expect(subject).to(
        eq("An introductory paragraph before the start of the body.")
      )
    end

    context "when configuration is set" do
      let(:template_class) { IndexTemplate }
      it { is_expected.to eq("This is the excerpt") }
    end

    context "when configuration is inherited" do
      let(:template_class) { InheritedTemplate }
      it { is_expected.to eq("This is the excerpt") }
    end
  end

  describe "#block_ids" do
    subject { template.block_ids }

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

  describe "#block_name" do
    let(:block) { :excerpt }
    subject { template.block_name(block) }
    it { is_expected.to eq("Standfirst") }

    context "when configuration is set" do
      let(:template_class) { IndexTemplate }
      it { is_expected.to eq("Excerpt") }
    end

    context "when configuration is inherited" do
      let(:template_class) { InheritedTemplate }
      it { is_expected.to eq("Excerpt") }
    end
  end

  describe "#block_placeholder" do
    let(:block) { :excerpt }
    subject { template.block_placeholder(block) }

    it { is_expected.to eq(nil) }

    context "when configuration is set" do
      let(:template_class) { IndexTemplate }
      it { is_expected.to eq("Placeholder excerpt") }
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
end
