# frozen_string_literal: true

require "rails_helper"

describe PagesCore::SearchableDocument, type: :model do
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
end
