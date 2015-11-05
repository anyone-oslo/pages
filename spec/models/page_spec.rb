# encoding: utf-8

require "rails_helper"

describe Page do
  describe ".archive_finder" do
    subject { Page.archive_finder }
    it { is_expected.to be_a(PagesCore::ArchiveFinder) }
    specify { expect(subject.timestamp_attribute).to eq(:published_at) }
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
end
