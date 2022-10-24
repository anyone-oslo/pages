# frozen_string_literal: true

require "rails_helper"

describe Page, type: :model do
  describe ".archive_finder" do
    subject(:finder) { described_class.archive_finder }

    it { is_expected.to be_a(PagesCore::ArchiveFinder) }
    specify { expect(finder.timestamp_attribute).to eq(:published_at) }
  end

  describe ".enabled_feeds" do
    subject { described_class.enabled_feeds(I18n.default_locale, options) }

    let(:options) { {} }

    context "with no pages" do
      it { is_expected.to eq([]) }
    end

    context "with no arguments" do
      let!(:page) { create(:page, feed_enabled: true) }

      before do
        create(:hidden_page, feed_enabled: true)
        create(:page, feed_enabled: true, locale: "fr")
      end

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
    subject { described_class.published }

    let!(:published_page) { create(:page) }
    let!(:hidden_page) { create(:page, status: 3) }
    let!(:autopublish_page) do
      create(:page, published_at: (Time.now.utc + 2.hours))
    end

    it { is_expected.to include(published_page) }
    it { is_expected.not_to include(hidden_page) }
    it { is_expected.not_to include(autopublish_page) }
  end

  describe ".order_by_tags" do
    subject do
      described_class.localized(I18n.default_locale).order_by_tags([foo, bar])
    end

    let(:foo) { Tag.create(name: "Foo") }
    let(:bar) { Tag.create(name: "Bar") }
    let!(:page1) { create(:page, tag_list: [Tag.create(name: "Baz")]) }
    let!(:page2) { create(:page, tag_list: [foo, bar]) }
    let!(:page3) { create(:page, tag_list: [foo]) }

    it { is_expected.to match_array([page3, page2, page1]) }
  end

  describe ".localized" do
    subject { described_class.localized("nb") }

    let!(:norwegian_page) { described_class.create(name: "Test", locale: "nb") }
    let!(:english_page) { described_class.create(name: "Test", locale: "en") }

    it { is_expected.to include(norwegian_page) }
    it { is_expected.not_to include(english_page) }
  end

  describe ".locales" do
    subject { page.locales }

    let(:page) do
      described_class.create(
        excerpt: { "en" => "My test page", "nb" => "Testside" },
        locale: "en"
      )
    end

    it { is_expected.to match(%w[en nb]) }
  end

  describe ".status_labels" do
    subject(:labels) { described_class.status_labels }

    it "returns the status labels" do
      expect(labels).to eq(0 => "Draft",
                           1 => "Reviewed",
                           2 => "Published",
                           3 => "Hidden",
                           4 => "Deleted")
    end
  end

  describe "with ancestors" do
    let(:root)   { described_class.create }
    let(:parent) { described_class.create(parent: root) }
    let(:page)   { described_class.create(parent: parent) }

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
      described_class.create(
        excerpt: { "en" => "My test page", "nb" => "Testside" },
        locale: "en"
      )
    end

    it "responds with the locale specific string" do
      expect(page.excerpt.to_s).to eq("My test page")
    end

    it "sets the other locale" do
      expect(page.localize("nb").excerpt.to_s).to eq("Testside")
    end

    it "has multiple locales" do
      expect(page.locales).to match(%w[en nb])
    end
  end

  describe "removing a locale" do
    let(:page) do
      described_class.create(
        excerpt: { "en" => "My test page", "nb" => "Testside" },
        locale: "en"
      )
    end

    before do
      page.update(excerpt: "")
      page.reload
    end

    it "removes the unnecessary locales" do
      expect(page.locales).to match(["nb"])
    end
  end

  describe "uninitialized localization" do
    let(:page) { described_class.new }

    specify { expect(page.body?).to be(false) }
    specify { expect(page.body).to be_a(String) }
  end

  describe "with an excerpt" do
    let(:page) { described_class.create(excerpt: "My test page", locale: "en") }

    it "responds to excerpt?" do
      expect(page.excerpt?).to be(true)
    end

    it "returns a string" do
      expect(page.excerpt).to be_a(String)
    end

    it "excerpt should be a localization" do
      expect(page.excerpt.to_s).to eq("My test page")
    end

    it "is changed when saved" do
      page.update(excerpt: "Hi")
      page.reload
      expect(page.excerpt.to_s).to eq("Hi")
    end

    it "removes the localization when nilified" do
      page.update(excerpt: nil)
      expect(page.excerpt?).to be(false)
    end
  end

  describe "#empty?" do
    subject { page.empty? }

    context "when page is empty" do
      let(:page) { build(:page) }

      it { is_expected.to be(true) }
    end

    context "when page has excerpt" do
      let(:page) { build(:page, excerpt: "e") }

      it { is_expected.to be(false) }
    end

    context "when page has body" do
      let(:page) { build(:page, body: "b") }

      it { is_expected.to be(false) }
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

      it { is_expected.to be(false) }
    end

    context "with no body" do
      let(:page) { build(:page, excerpt: "e") }

      it { is_expected.to be(false) }
    end

    context "with no excerpt" do
      let(:page) { build(:page, body: "b") }

      it { is_expected.to be(false) }
    end

    context "with body and excerpt" do
      let(:page) { build(:page, body: "b", excerpt: "e") }

      it { is_expected.to be(true) }
    end
  end

  describe "#subpages" do
    subject { page.subpages.map(&:id) }

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
             published_at: 1.day.ago)
    end

    context "when page is a regular page" do
      let(:page) { create(:page) }

      it { is_expected.to eq([page3.id, page1.id, page2.id]) }
    end

    context "when page is a news page" do
      let(:page) { create(:page, news_page: true) }

      it { is_expected.to eq([page1.id, page3.id, page2.id]) }
    end
  end

  describe "#move" do
    let!(:page) { create(:page) }
    let!(:root) { create(:page) }
    let!(:before) { create(:page, parent: root, position: 1) }
    let!(:after) { create(:page, parent: root, position: 2) }

    context "with another parent" do
      before do
        page.move(parent: root, position: 2)
        [root, before, after].each(&:reload)
      end

      it "updates the positions" do
        expect([before, page, after].map(&:position)).to eq([1, 2, 3])
      end
    end

    context "when within the same parent" do
      let!(:page) { create(:page, parent: root, position: 3) }

      before do
        page.move(parent: root, position: 2)
        [root, before, after].each(&:reload)
      end

      it "updates the positions" do
        expect([before, page, after].map(&:position)).to eq([1, 2, 3])
      end
    end

    context "when moving to the root" do
      let!(:page) { create(:page, parent: root, position: 3) }

      before do
        page.move(parent: nil, position: 1)
        [root, before, after].each(&:reload)
      end

      it "moves the page" do
        expect(page.parent).to be_nil
      end

      it "updates the positions" do
        expect([page, root].map(&:position)).to eq([1, 2])
      end
    end
  end

  describe "#position" do
    context "when creating a page" do
      subject { page.position }

      let(:page) { create(:page) }

      it { is_expected.to eq(1) }
    end

    context "when creating a deleted page" do
      subject { page.position }

      let(:page) { create(:page, status: 4) }

      it { is_expected.to be_nil }
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

      it "updates the positions on the new parent" do
        expect([page1, page3].map(&:position)).to eq([1, 2])
      end

      it "updates the position on lower items" do
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

      it "removes the list position" do
        expect(page1.position).to be_nil
      end

      it "updates the position on lower items" do
        expect(page2.position).to eq(1)
      end
    end

    context "when restoring a page" do
      let(:page) { create(:page, status: 4) }

      before do
        create(:page, position: 1)
        page.update(status: 2)
      end

      it "appends it to the list" do
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

      it "updates the position on lower items" do
        expect(page2.position).to eq(1)
      end
    end
  end
end
