# encoding: utf-8

require "spec_helper"

describe PagesCore::ArchiveFinder do
  let(:parent_page) { create(:page) }

  let(:page1) do
    create(
      :page,
      published_at: DateTime.parse("2012-03-01 12:00"),
      parent: parent_page,
      locale: "nb",
      name: "Foo1"
    )
  end
  let(:page2) do
    create(
      :page,
      published_at: DateTime.parse("2012-04-05 12:00"),
      parent: parent_page,
      locale: "nb",
      name: "Foo2"
    )
  end
  let(:page3) do
    create(
      :page,
      published_at: DateTime.parse("2012-04-06 12:00"),
      parent: parent_page,
      locale: "nb",
      name: "Foo3"
    )
  end
  let(:page4) do
    create(
      :page,
      published_at: DateTime.parse("2013-01-27 12:00"),
      parent: parent_page,
      locale: "nb",
      name: "Foo4"
    )
  end
  let(:pages) { [page1, page2, page3, page4] }

  let(:archive_finder) do
    PagesCore::ArchiveFinder.new(parent_page.pages, timestamp: :published_at)
  end

  describe "#by_year" do
    before { pages }
    subject { archive_finder.by_year(2012) }
    it { is_expected.to match([page1, page2, page3]) }
    context "when parent page has locale" do
      let(:parent_page) { create(:page, locale: "nb") }
      before { pages }
      it { is_expected.to match([page1, page2, page3]) }
    end
  end

  describe "#by_year_and_month" do
    before { pages }
    subject { archive_finder.by_year_and_month(2012, 4) }
    it { is_expected.to match([page2, page3]) }
    context "when parent page has locale" do
      let(:parent_page) { create(:page, locale: "nb") }
      before { pages }
      it { is_expected.to match([page2, page3]) }
    end
  end

  describe "#latest_year_and_month" do
    subject { archive_finder.latest_year_and_month }
    context "without items" do
      it { is_expected.to be_nil }
    end
    context "with items" do
      before { pages }
      it { is_expected.to eq([2013, 1]) }
    end
    context "when parent page has locale" do
      let(:parent_page) { create(:page, locale: "nb") }
      before { pages }
      it { is_expected.to eq([2013, 1]) }
    end
  end

  describe "#months_in_year" do
    subject { archive_finder.months_in_year("2012") }
    context "without items" do
      it { is_expected.to eq([]) }
    end
    context "with items" do
      before { pages }
      it { is_expected.to eq([3, 4]) }
    end
    context "when parent page has locale" do
      let(:parent_page) { create(:page, locale: "nb") }
      before { pages }
      it { is_expected.to eq([3, 4]) }
    end
  end

  describe "#months_in_year_with_count" do
    subject { archive_finder.months_in_year_with_count("2012") }
    context "without items" do
      it { is_expected.to eq([]) }
    end
    context "with items" do
      before { pages }
      it { is_expected.to eq([[3, 1], [4, 2]]) }
    end
    context "when parent page has locale" do
      let(:parent_page) { create(:page, locale: "nb") }
      before { pages }
      it { is_expected.to eq([[3, 1], [4, 2]]) }
    end
  end

  describe "#timestamp_attribute" do
    subject { archive_finder.timestamp_attribute }
    context "without options" do
      let(:archive_finder) { PagesCore::ArchiveFinder.new(Page.visible) }
      it { is_expected.to eq(:created_at) }
    end
    context "with options" do
      let(:archive_finder) do
        PagesCore::ArchiveFinder.new(Page.visible, timestamp: :published_at)
      end
      it { is_expected.to eq(:published_at) }
    end
  end

  describe "#years" do
    subject { archive_finder.years }
    context "without items" do
      it { is_expected.to eq([]) }
    end
    context "with items" do
      before { pages }
      it { is_expected.to eq([2012, 2013]) }
    end
    context "when parent page has locale" do
      let(:parent_page) { create(:page, locale: "nb") }
      before { pages }
      it { is_expected.to eq([2012, 2013]) }
    end
  end
end
