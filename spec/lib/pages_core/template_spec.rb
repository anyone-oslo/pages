require "rails_helper"

describe PagesCore::Template do
  let(:template_class) { ApplicationTemplate }
  let(:template) { template_class.new }

  before { I18n.locale = :en }
  after { I18n.locale = I18n.default_locale }

  describe ".find" do
    let(:id) { :news_item }
    subject { PagesCore::Template.find(id) }

    it { is_expected.to eq(NewsItemTemplate) }

    context "when template doesn't exist" do
      let(:id) { :foo }
      it "should raise an error" do
        expect { subject }.to raise_error(PagesCore::Template::NotFoundError)
      end
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

  describe "#render" do
    subject { template.render }

    it { is_expected.to be_a(Proc) }

    context "with a custom proc" do
      let(:template_class) { IndexTemplate }

      it "should return the proc" do
        expect(subject.call).to eq("foo")
      end
    end
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
