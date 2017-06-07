require "rails_helper"

RSpec.describe PagesCore::MetaTagsHelper, type: :helper do
  let(:page) { build(:page, meta_description: "meta", excerpt: "excerpt") }

  describe "#default_meta_image" do
    subject { helper.default_meta_image }

    context "when image isn't set" do
      it { is_expected.to eq(nil) }
    end

    context "when image is set" do
      before { helper.default_meta_image "foo.png" }
      it { is_expected.to eq("foo.png") }
    end
  end

  describe "#default_meta_image?" do
    subject { helper.default_meta_image? }

    context "when image isn't set" do
      it { is_expected.to eq(false) }
    end

    context "when image is set" do
      before { helper.default_meta_image "foo.png" }
      it { is_expected.to eq(true) }
    end
  end

  describe "#meta_description" do
    subject { helper.meta_description }

    context "when description isn't set" do
      it { is_expected.to eq(nil) }
    end

    context "with a page" do
      before { helper.instance_variable_set(:@page, page) }

      context "when description is set" do
        before { helper.meta_description "<b>Description</b>" }
        it { is_expected.to eq("Description") }
      end

      context "with meta description set" do
        it { is_expected.to eq(page.meta_description) }
      end

      context "with excerpt fallback" do
        let(:page) { build(:page, excerpt: "excerpt") }
        it { is_expected.to eq(page.excerpt) }
      end
    end
  end

  describe "#meta_description?" do
    subject { helper.meta_description? }

    context "when description isn't set" do
      it { is_expected.to eq(false) }
    end

    context "when description is set" do
      before { helper.meta_description "description" }
      it { is_expected.to eq(true) }
    end
  end

  describe "#meta_image" do
    let(:image) { create(:image) }
    subject { helper.meta_image }
    before { helper.instance_variable_set(:@page, page) }

    context "when image isn't set" do
      it { is_expected.to eq(nil) }
    end

    context "when set to a string" do
      before { helper.meta_image("foo.png") }
      it { is_expected.to eq("foo.png") }
    end

    context "when set to an image" do
      before { helper.meta_image(image) }
      it { is_expected.to match(%r{^http://test.host/dynamic_images/}) }
    end

    context "when page has a meta image" do
      let(:page) { create(:page, meta_image: image) }
      it { is_expected.to match(%r{^http://test.host/dynamic_images/}) }
    end

    context "when default_meta_image is set" do
      before { helper.default_meta_image "default.png" }
      it { is_expected.to eq("default.png") }

      context "and page has an image" do
        let(:page) { create(:page, image: image) }
        it { is_expected.to match(%r{^http://test.host/dynamic_images/}) }
      end
    end
  end

  describe "#meta_image?" do
    subject { helper.meta_image? }

    context "when image isn't set" do
      it { is_expected.to eq(false) }
    end

    context "when image is set" do
      before { helper.meta_image("foo.png") }
      it { is_expected.to eq(true) }
    end
  end

  describe "#meta_keywords" do
    let(:page) { create(:page) }
    before { helper.instance_variable_set(:@page, page) }
    subject { helper.meta_keywords }

    context "when not set" do
      it { is_expected.to eq(nil) }
    end

    context "when keywords have been set" do
      before { helper.meta_keywords(%w[Foo Bar]) }
      it { is_expected.to eq("Foo, Bar") }
    end

    context "when page has tags" do
      before do
        page.tag_with(create(:tag, name: "foo"))
        page.tag_with(create(:tag, name: "bar"))
        page.reload
      end

      it { is_expected.to eq("bar, foo") }
    end
  end

  describe "#meta_keywords?" do
    subject { helper.meta_keywords? }

    context "when keywords hasn't been set" do
      it { is_expected.to eq(false) }
    end

    context "when keywords have been set" do
      before { helper.meta_keywords(%w[Foo Bar]) }
      it { is_expected.to eq(true) }
    end
  end
end
