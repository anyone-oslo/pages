# encoding: utf-8

require "rails_helper"

describe Page, type: :model do
  describe ".archive_finder" do
    subject { Page.archive_finder }
    it { is_expected.to be_a(PagesCore::ArchiveFinder) }
    specify { expect(subject.timestamp_attribute).to eq(:published_at) }
  end

  describe ".enabled_feeds" do
    let(:options) { {} }
    subject { Page.enabled_feeds(I18n.default_locale, options) }

    context "with no pages" do
      it { is_expected.to eq([]) }
    end

    context "with no arguments" do
      let!(:page) { create(:page, feed_enabled: true) }
      let!(:hidden) { create(:hidden_page, feed_enabled: true) }
      let!(:other_locale) { create(:page, feed_enabled: true, locale: "fr") }
      it { is_expected.to match_array([page]) }
    end

    context "with include_hidden" do
      let(:options) { { include_hidden: true } }
      let!(:page) { create(:page, feed_enabled: true) }
      let!(:hidden) { create(:page, feed_enabled: true, status: 3) }
      it { is_expected.to match_array([page, hidden]) }
    end
  end

  describe ".published" do
    let!(:published_page) { create(:page) }
    let!(:hidden_page) { create(:page, status: 3) }
    let!(:autopublish_page) do
      create(:page, published_at: (Time.now + 2.hours))
    end
    subject { Page.published }
    it { is_expected.to include(published_page) }
    it { is_expected.not_to include(hidden_page) }
    it { is_expected.not_to include(autopublish_page) }
  end

  describe ".order_by_tags" do
    let(:foo) { Tag.create(name: "Foo") }
    let(:bar) { Tag.create(name: "Bar") }
    let(:baz) { Tag.create(name: "Baz") }
    let!(:page1) { create(:page, tag_list: [baz]) }
    let!(:page2) { create(:page, tag_list: [foo, bar]) }
    let!(:page3) { create(:page, tag_list: [foo]) }

    subject { Page.localized(I18n.default_locale).order_by_tags([foo, bar]) }

    it { is_expected.to match_array([page3, page2, page1]) }
  end

  describe ".localized" do
    let!(:norwegian_page) { Page.create(name: "Test", locale: "nb") }
    let!(:english_page) { Page.create(name: "Test", locale: "en") }
    subject { Page.localized("nb") }
    it { is_expected.to include(norwegian_page) }
    it { is_expected.not_to include(english_page) }
  end

  describe ".locales" do
    let(:page) do
      Page.create(
        excerpt: { "en" => "My test page", "nb" => "Testside" },
        locale: "en"
      )
    end
    subject { page.locales }
    it { is_expected.to match(%w(en nb)) }
  end

  describe ".status_labels" do
    subject { Page.status_labels }
    it "should return the status labels" do
      expect(subject).to eq(
        {
          0 => "Draft",
          1 => "Reviewed",
          2 => "Published",
          3 => "Hidden",
          4 => "Deleted"
        }
      )
    end
  end

  describe "with ancestors" do
    let(:root)   { Page.create }
    let(:parent) { Page.create(parent: root) }
    let(:page)   { Page.create(parent: parent) }

    it "belongs to the parent" do
      expect(page.parent).to eq(parent)
    end

    it "is a child of root" do
      expect(page.ancestors).to include(root)
    end

    it "has both as ancestors" do
      expect(page.ancestors).to eq([parent, root])
    end

    it "has a root page" do
      expect(page.root).to eq(root)
    end
  end

  describe "setting multiple locales" do
    let(:page) do
      Page.create(
        excerpt: { "en" => "My test page", "nb" => "Testside" },
        locale: "en"
      )
    end

    it "should respond with the locale specific string" do
      expect(page.excerpt?).to eq(true)
      expect(page.excerpt.to_s).to eq("My test page")
      expect(page.localize("nb").excerpt.to_s).to eq("Testside")
    end

    it "should remove the unnecessary locales" do
      expect(page.locales).to match(%w(en nb))
      page.update(excerpt: "")
      page.reload
      expect(page.locales).to match(["nb"])
    end
  end

  it "should return a blank Localization for uninitialized columns" do
    page = Page.new
    expect(page.body?).to eq(false)
    expect(page.body).to be_a(String)
  end

  describe "with an excerpt" do
    let(:page) { Page.create(excerpt: "My test page", locale: "en") }

    it "responds to excerpt?" do
      expect(page.excerpt?).to eq(true)
      page.excerpt = nil
      expect(page.excerpt?).to eq(false)
    end

    it "excerpt should be a localization" do
      expect(page.excerpt).to be_kind_of(String)
      expect(page.excerpt.to_s).to eq("My test page")
    end

    it "should be changed when saved" do
      page.update(excerpt: "Hi")
      page.reload
      expect(page.excerpt.to_s).to eq("Hi")
    end

    it "should remove the localization when nilified" do
      page.update(excerpt: nil)
      expect(page.valid?).to eq(true)
      page.reload
      expect(page.excerpt?).to eq(false)
    end
  end

  describe "#comments_closed_after_time?" do
    subject { page.comments_closed_after_time? }

    context "when close_comments_after is configured" do
      before { PagesCore.config.close_comments_after = 14.days }

      context "and page is past" do
        let(:page) { build(:page, published_at: 15.days.ago) }
        it { is_expected.to eq(true) }
      end

      context "and page isn't past" do
        let(:page) { build(:page, published_at: 10.days.ago) }
        it { is_expected.to eq(false) }
      end
    end

    context "when close_comments_after is configured" do
      before { PagesCore.config.close_comments_after = nil }

      let(:page) { build(:page, published_at: 90.days.ago) }
      it { is_expected.to eq(false) }
    end
  end

  describe "#comments_allowed?" do
    subject { page.comments_allowed? }

    context "when comments are automatically closed" do
      before { PagesCore.config.close_comments_after = 14.days }
      let(:page) do
        build(:page, published_at: 15.days.ago, comments_allowed: true)
      end
      it { is_expected.to eq(false) }
    end

    context "when comments haven't automatically been closed" do
      let(:page) { build(:page, comments_allowed: true) }
      it { is_expected.to eq(true) }
    end
  end

  describe "#empty?" do
    subject { page.empty? }

    context "when page is empty" do
      let(:page) { build(:page) }
      it { is_expected.to eq(true) }
    end

    context "when page has excerpt" do
      let(:page) { build(:page, excerpt: "e") }
      it { is_expected.to eq(false) }
    end

    context "when page has body" do
      let(:page) { build(:page, body: "b") }
      it { is_expected.to eq(false) }
    end
  end

  describe "#excerpt_or_body" do
    subject { page.excerpt_or_body }

    context "with no attributes" do
      let(:page) { build(:page) }
      it { is_expected.to eq("") }
    end

    context "with no excerpt" do
      let(:page) { build(:page, body: "b") }
      it { is_expected.to eq("b") }
    end

    context "with excerpt" do
      let(:page) { build(:page, body: "b", excerpt: "e") }
      it { is_expected.to eq("e") }
    end
  end

  describe "#extended?" do
    subject { page.extended? }

    context "with no attributes" do
      let(:page) { build(:page) }
      it { is_expected.to eq(false) }
    end

    context "with no body" do
      let(:page) { build(:page, excerpt: "e") }
      it { is_expected.to eq(false) }
    end

    context "with no excerpt" do
      let(:page) { build(:page, body: "b") }
      it { is_expected.to eq(false) }
    end

    context "with body and excerpt" do
      let(:page) { build(:page, body: "b", excerpt: "e") }
      it { is_expected.to eq(true) }
    end
  end

  describe "#subpages" do
    let!(:page1) do
      create(:page,
             position: 2,
             pinned: true,
             parent: page,
             published_at: 3.days.ago)
    end

    let!(:page2) do
      create(:page,
             position: 3,
             parent: page,
             published_at: 2.days.ago)
    end

    let!(:page3) do
      create(:page,
             position: 1,
             parent: page,
             published_at: 1.days.ago)
    end

    subject { page.subpages.map(&:id) }

    context "when page is a regular page" do
      let(:page) { create(:page) }
      it { is_expected.to eq([page3.id, page1.id, page2.id]) }
    end

    context "when page is a news page" do
      let(:page) { create(:page, news_page: true) }
      it { is_expected.to eq([page1.id, page3.id, page2.id]) }
    end
  end

  describe "#position" do
    context "creating a page" do
      let(:page) { create(:page) }
      subject { page.position }
      it { is_expected.to eq(1) }
    end

    context "creating a deleted page" do
      let(:page) { create(:page, status: 4) }
      subject { page.position }
      it { is_expected.to eq(nil) }
    end

    context "when moving a page" do
      let!(:page) { create(:page) }
      let(:parent) { root }
      let(:position) { 2 }
      let!(:root) { create(:page) }
      let!(:before) { create(:page, parent: root, position: 1) }
      let!(:after) { create(:page, parent: root, position: 2) }

      before do
        page.move(parent: parent, position: position)
        root.reload
        before.reload
        after.reload
      end

      context "to another parent" do
        it "should update the positions" do
          expect(before.position).to eq(1)
          expect(page.position).to eq(2)
          expect(after.position).to eq(3)
        end
      end

      context "within the same parent" do
        let!(:page) { create(:page, parent: root, position: 3) }
        it "should update the positions" do
          expect(before.position).to eq(1)
          expect(page.position).to eq(2)
          expect(after.position).to eq(3)
        end
      end

      context "to the root" do
        let(:parent) { nil }
        let(:position) { 1 }
        let!(:page) { create(:page, parent: root, position: 3) }

        it "should move the page" do
          expect(page.parent).to eq(nil)
          expect(page.position).to eq(1)
          expect(root.position).to eq(2)
        end
      end
    end

    context "when changing parent" do
      let!(:root1) { create(:page) }
      let!(:root2) { create(:page) }
      let!(:page1) { create(:page, position: 1, parent: root1) }
      let!(:page2) { create(:page, position: 2, parent: root1) }
      let!(:page3) { create(:page, position: 1, parent: root2) }

      before do
        page1.update(parent: root2)
        page2.reload
        page3.reload
      end

      it "should update the positions on the new parent" do
        expect(page1.position).to eq(1)
        expect(page3.position).to eq(2)
      end

      it "should update the position on lower items" do
        expect(page2.position).to eq(1)
      end
    end

    context "when deleting a page" do
      let!(:page1) { create(:page, position: 1) }
      let!(:page2) { create(:page, position: 2) }

      before do
        page1.update(status: 4)
        page2.reload
      end

      it "should remove the list position" do
        expect(page1.position).to eq(nil)
      end

      it "should update the position on lower items" do
        expect(page2.position).to eq(1)
      end
    end

    context "when restoring a page" do
      let!(:previous_page) { create(:page, position: 1) }
      let!(:page) { create(:page, status: 4) }

      before { page.update(status: 2) }

      it "should append it to the list" do
        expect(page.position).to eq(2)
      end
    end

    context "when destroying a page" do
      let!(:page1) { create(:page, position: 1) }
      let!(:page2) { create(:page, position: 2) }

      before do
        page1.destroy
        page2.reload
      end

      it "should update the position on lower items" do
        expect(page2.position).to eq(1)
      end
    end
  end
end
