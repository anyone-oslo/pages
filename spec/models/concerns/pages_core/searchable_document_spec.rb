# frozen_string_literal: true

require "rails_helper"

describe PagesCore::SearchableDocument do
  subject { page }

  let(:page) { create(:page) }

  it { is_expected.to have_many(:search_documents).dependent(:destroy) }

  specify { expect(page.search_documents.count).to eq(1) }

  describe "with multiple locales" do
    let(:page) do
      create(:page,
             name: { en: "Hello", nb: "Heisann" },
             excerpt: { en: "excerpt" },
             body: { en: "body", nb: "brødtekst" })
    end

    it "creates both search documents" do
      expect(page.search_documents.count).to eq(2)
    end

    describe "the english document" do
      subject(:doc) { page.search_documents.find_by(locale: :en) }

      specify { expect(doc.name).to eq("Hello") }
      specify { expect(doc.content).to match("excerpt") }
      specify { expect(doc.content).to match("body") }
    end
  end

  describe "indexing stored markup" do
    subject(:doc) { page.search_documents.find_by(locale: :en) }

    context "with Textile excerpt and body" do
      let(:page) do
        create(:page,
               locale: :en,
               excerpt: "a *short* lead",
               body: "the rest of the story")
      end

      specify { expect(doc.content).to match("short") }
      specify { expect(doc.content).to match("story") }
      specify { expect(doc.description).to eq("a *short* lead") }
    end

    context "with document-wrapped excerpt and body" do
      let(:page) do
        create(:page,
               locale: :en,
               excerpt: "<notextile>\n<p>a <strong>short</strong> lead</p>\n</notextile>",
               body: "<notextile>\n<p>the rest of the story</p>\n</notextile>")
      end

      specify { expect(doc.content).to match("short") }
      specify { expect(doc.content).to match("story") }
      specify { expect(doc.content).not_to match("notextile") }
      specify { expect(doc.content).not_to include("<p>") }
      specify { expect(doc.description).to eq("a short lead") }
    end
  end
end
