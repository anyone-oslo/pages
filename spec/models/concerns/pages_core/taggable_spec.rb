# frozen_string_literal: true

require "rails_helper"

describe PagesCore::Taggable do
  subject(:page) { create(:page) }

  it { is_expected.to have_many(:taggings).dependent(:destroy) }
  it { is_expected.to have_many(:tags).through(:taggings) }

  describe ".tagged_with" do
    let(:foo) { create(:tag, name: "foo") }
    let(:bar) { create(:tag, name: "bar") }
    let(:other_page) { create(:page) }

    before do
      page.tag_with!(foo)
      other_page.tag_with!(bar)
    end

    context "with tag argument" do
      subject { Page.tagged_with(foo) }

      it { is_expected.to eq([page]) }
    end

    context "with string argument" do
      subject { Page.tagged_with("foo") }

      it { is_expected.to eq([page]) }
    end

    context "with array argument" do
      subject { Page.tagged_with(%w[foo bar]).map(&:id) }

      it { is_expected.to match_array([page, other_page].map(&:id)) }
    end

    context "with multiple arguments" do
      subject { Page.tagged_with(foo, bar).map(&:id) }

      it { is_expected.to match_array([page, other_page].map(&:id)) }
    end
  end

  describe "#serialized_tags" do
    subject { page.serialized_tags }

    before { page.tag_with!(%w[foo bar]) }

    it { is_expected.to eq(%w[bar foo].to_json) }
  end

  describe "#serialized_tags=" do
    let(:json) { %w[foo bar].to_json }

    context "when creating" do
      let(:page) { create(:page, serialized_tags: json) }

      specify { expect(page.tags.count).to eq(2) }
    end

    context "when updating" do
      before { page.update(serialized_tags: json) }

      specify { expect(page.tags.count).to eq(2) }
    end
  end

  describe "#tag_with!" do
    context "with string argument" do
      before { page.tag_with!("foo, bar") }

      specify { expect(page.tags.count).to eq(2) }
    end

    context "with array argument" do
      before { page.tag_with!(%w[foo bar]) }

      specify { expect(page.tags.count).to eq(2) }
    end

    context "with tags array argument" do
      before { page.tag_with!(create_list(:tag, 2)) }

      specify { expect(page.tags.count).to eq(2) }
    end

    context "with splatted array argument" do
      before { page.tag_with!("foo", "bar") }

      specify { expect(page.tags.count).to eq(2) }
    end
  end

  describe "#tag_list=" do
    context "when creating" do
      let(:page) { create(:page, tag_list: "foo, bar, baz") }

      specify { expect(page.tags.count).to eq(3) }
    end

    context "when updating" do
      before { page.update(tag_list: "foo, bar") }

      specify { expect(page.tags.count).to eq(2) }
    end
  end

  describe "#tag_list" do
    subject { page.tag_list }

    context "without tags" do
      it { is_expected.to eq("") }
    end

    context "with tags" do
      before do
        page.tag_with!("foo, bar")
        page.reload
      end

      it { is_expected.to eq("bar, foo") }
    end
  end
end
