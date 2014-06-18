# encoding: utf-8

require 'spec_helper'

describe PagesCore::ArchiveFinder do
  let(:page1) { create(:page, published_at: DateTime.parse('2012-03-01 12:00')) }
  let(:page2) { create(:page, published_at: DateTime.parse('2012-04-05 12:00')) }
  let(:page3) { create(:page, published_at: DateTime.parse('2012-04-06 12:00')) }
  let(:page4) { create(:page, published_at: DateTime.parse('2013-01-27 12:00')) }
  let(:pages) { [page1, page2, page3, page4] }
  let(:archive_finder) { PagesCore::ArchiveFinder.new(Page.visible, timestamp: :published_at) }

  describe "#by_year" do
    before { pages }
    subject { archive_finder.by_year(2012) }
    it { should =~ [page1, page2, page3] }
  end

  describe "#by_year_and_month" do
    before { pages }
    subject { archive_finder.by_year_and_month(2012, 4) }
    it { should =~ [page2, page3] }
  end

  describe "#latest_year_and_month" do
    subject { archive_finder.latest_year_and_month }
    context "without items" do
      it { should be_nil }
    end
    context "with items" do
      before { pages }
      it { should == [2013, 1] }
    end
  end

  describe "#months_in_year" do
    subject { archive_finder.months_in_year('2012') }
    context "without items" do
      it { should == [] }
    end
    context "with items" do
      before { pages }
      it { should == [3, 4] }
    end
  end

  describe "#months_in_year_with_count" do
    subject { archive_finder.months_in_year_with_count('2012') }
    context "without items" do
      it { should == [] }
    end
    context "with items" do
      before { pages }
      it { should == [[3, 1], [4, 2]] }
    end
  end

  describe "#timestamp_attribute" do
    subject { archive_finder.timestamp_attribute }
    context "without options" do
      let(:archive_finder) { PagesCore::ArchiveFinder.new(Page.visible) }
      it { should == :created_at }
    end
    context "with options" do
      let(:archive_finder) { PagesCore::ArchiveFinder.new(Page.visible, timestamp: :published_at) }
      it { should == :published_at }
    end
  end

  describe "#years" do
    subject { archive_finder.years }
    context "without items" do
      it { should == [] }
    end
    context "with items" do
      before { pages }
      it { should == [2012, 2013] }
    end
  end

end