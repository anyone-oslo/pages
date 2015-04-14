# encoding: utf-8

require "spec_helper"

describe PagesCore::Taggable do
  let(:page) { create(:page) }

  subject { page }

  it { is_expected.to have_many(:taggings).dependent(:destroy) }
  it { is_expected.to have_many(:tags).through(:taggings) }

  describe ".tagged_with" do
    let!(:foo) { create(:tag, name: "foo") }
    let!(:bar) { create(:tag, name: "bar") }
    let!(:page1) { create(:page) }
    let!(:page2) { create(:page) }

    before do
      page1.tag_with(foo)
      page2.tag_with(bar)
    end

    context "with tag argument" do
      subject { Page.tagged_with(foo) }
      it { is_expected.to eq([page1]) }
    end

    context "with string argument" do
      subject { Page.tagged_with("foo") }
      it { is_expected.to eq([page1]) }
    end

    context "with array argument" do
      subject { Page.tagged_with(%w(foo bar)) }
      it { is_expected.to match([page1, page2]) }
    end

    context "with multiple arguments" do
      subject { Page.tagged_with(foo, bar) }
      it { is_expected.to match([page1, page2]) }
    end
  end

  describe "#serialized_tags" do
    subject { page.serialized_tags }
    before { page.tag_with(%w(foo bar)) }
    it { is_expected.to eq(%w(bar foo).to_json) }
  end

  describe "#serialized_tags=" do
    let(:json) { %w(foo bar).to_json }
    before { page.update(serialized_tags: json) }
    specify { expect(page.tags.count).to eq(2) }
  end

  describe "#tag_with" do
    context "with string argument" do
      before { page.tag_with("foo, bar") }
      specify { expect(page.tags.count).to eq(2) }
    end

    context "with array argument" do
      before { page.tag_with(%w(foo bar)) }
      specify { expect(page.tags.count).to eq(2) }
    end

    context "with tags array argument" do
      before { page.tag_with([create(:tag), create(:tag)]) }
      specify { expect(page.tags.count).to eq(2) }
    end

    context "with splatted array argument" do
      before { page.tag_with("foo", "bar") }
      specify { expect(page.tags.count).to eq(2) }
    end
  end

  describe "#tag_list=" do
    before { page.tag_list = "foo, bar" }
    specify { expect(page.tags.count).to eq(2) }
  end

  describe "#tag_list" do
    subject { page.tag_list }

    context "without tags" do
      it { is_expected.to eq("") }
    end

    context "with tags" do
      before { page.tag_with("foo, bar") }
      it { is_expected.to eq("bar, foo") }
    end
  end
end
