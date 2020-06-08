# frozen_string_literal: true

require "rails_helper"

describe PagesCore::PageModel::Tree, type: :model do
  subject(:page) { create(:page) }

  it { is_expected.to belong_to(:parent).class_name("Page").optional }

  it do
    expect(page).to have_many(:children)
      .class_name("Page")
      .dependent(:destroy)
  end

  describe ".roots" do
    subject { Page.roots }

    let!(:pages) { [page, create(:page)] }

    it { is_expected.to eq(pages) }
    it { is_expected.to be_a(ActiveRecord::Relation) }
  end

  describe ".root" do
    subject { Page.root }

    before do
      page
      create(:page)
    end

    it { is_expected.to eq(page) }
  end

  describe "#ancestors" do
    subject { page.ancestors }

    context "without parents" do
      it { is_expected.to eq([]) }
    end

    context "with parents" do
      let(:root) { create(:page) }
      let(:subpage) { create(:page, parent: root) }
      let(:page) { create(:page, parent: subpage) }

      it { is_expected.to eq([subpage, root]) }
    end
  end

  describe "#next_sibling" do
    subject { page.next_sibling }

    let(:root) { create(:page) }

    context "when page has a next sibling" do
      let(:page) { create(:page, parent: root) }
      let(:second_last) { create(:page, parent: root) }

      before do
        page
        second_last
        create(:page, parent: root)
      end

      it { is_expected.to eq(second_last) }
    end

    context "when page does not have a next sibling" do
      let(:page) { create(:page, parent: root) }

      before do
        create(:page, parent: root)
        page
      end

      it { is_expected.to eq(nil) }
    end
  end

  describe "#parent" do
    subject(:parent) { page.parent }

    context "without parent" do
      it { is_expected.to be_nil }
    end

    context "with parent" do
      let(:parent_page) { create(:page) }
      let(:page) { create(:page, parent: parent_page).localize("en") }

      it { is_expected.to eq(parent) }
      specify { expect(parent.locale).to eq("en") }
    end
  end

  describe "#previous_sibling" do
    subject { page.previous_sibling }

    let(:root) { create(:page) }

    context "when page has a previous sibling" do
      let(:second) { create(:page, parent: root) }
      let(:page) { create(:page, parent: root) }

      before do
        create(:page, parent: root)
        second
        page
      end

      it { is_expected.to eq(second) }
    end

    context "when page does not have a previous sibling" do
      let(:page) { create(:page, parent: root) }
      let(:last) { create(:page, parent: root) }

      before do
        page
        last
      end

      it { is_expected.to eq(nil) }
    end
  end

  describe "#root" do
    subject { page.root }

    context "when root page" do
      it { is_expected.to eq(page) }
    end

    context "when subpage" do
      let(:second_root) { create(:page) }
      let(:subpage) { create(:page, parent: second_root) }
      let(:page) { create(:page, parent: subpage) }

      before { create(:page) }

      it { is_expected.to eq(second_root) }
    end
  end

  describe "#self_and_ancestors" do
    subject { page.self_and_ancestors }

    context "without parents" do
      it { is_expected.to eq([page]) }
    end

    context "with parents" do
      let(:root) { create(:page) }
      let(:subpage) { create(:page, parent: root) }
      let(:page) { create(:page, parent: subpage) }

      it { is_expected.to eq([page, subpage, root]) }
    end
  end

  describe "#siblings" do
    subject { page.siblings }

    let(:root) { create(:page) }

    context "when page is a subpage" do
      let!(:first) { create(:page, parent: root) }
      let!(:page) { create(:page, parent: root) }
      let!(:third) { create(:page, parent: root) }

      it { is_expected.to eq([first, page, third]) }
    end

    context "when page is a root page" do
      let!(:first) { create(:page) }
      let!(:page) { create(:page) }
      let!(:third) { create(:page) }

      it { is_expected.to eq([first, page, third]) }
    end
  end
end
