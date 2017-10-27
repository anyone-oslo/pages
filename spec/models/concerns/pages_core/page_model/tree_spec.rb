require "rails_helper"

describe PagesCore::PageModel::Tree, type: :model do
  let(:page) { create(:page) }

  subject { page }

  it { is_expected.to belong_to(:parent).class_name("Page") }
  it do
    is_expected.to have_many(:children)
      .class_name("Page")
      .dependent(:destroy)
  end

  describe ".roots" do
    let!(:pages) { [page, create(:page)] }
    subject { Page.roots }
    it { is_expected.to eq(pages) }
    it { is_expected.to be_a(ActiveRecord::Relation) }
  end

  describe ".root" do
    let!(:pages) { [page, create(:page)] }
    subject { Page.root }
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
      let!(:page) { create(:page, parent: root) }
      let!(:second_last) { create(:page, parent: root) }
      let!(:last) { create(:page, parent: root) }
      it { is_expected.to eq(second_last) }
    end

    context "when page does not have a next sibling" do
      let!(:first) { create(:page, parent: root) }
      let!(:page) { create(:page, parent: root) }
      it { is_expected.to eq(nil) }
    end
  end

  describe "#parent" do
    subject { page.parent }

    context "without parent" do
      it { is_expected.to be_nil }
    end

    context "with parent" do
      let(:parent) { create(:page) }
      let(:page) { create(:page, parent: parent).localize("en") }
      it { is_expected.to eq(parent) }
      specify { expect(subject.locale).to eq("en") }
    end
  end

  describe "#previous_sibling" do
    subject { page.previous_sibling }

    let(:root) { create(:page) }

    context "when page has a previous sibling" do
      let!(:first) { create(:page, parent: root) }
      let!(:second) { create(:page, parent: root) }
      let!(:page) { create(:page, parent: root) }
      it { is_expected.to eq(second) }
    end

    context "when page does not have a previous sibling" do
      let!(:page) { create(:page, parent: root) }
      let!(:last) { create(:page, parent: root) }
      it { is_expected.to eq(nil) }
    end
  end

  describe "#root" do
    subject { page.root }

    context "when root page" do
      it { is_expected.to eq(page) }
    end

    context "when subpage" do
      let!(:root) { create(:page) }
      let(:second_root) { create(:page) }
      let(:subpage) { create(:page, parent: second_root) }
      let(:page) { create(:page, parent: subpage) }
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
