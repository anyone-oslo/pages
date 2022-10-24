# frozen_string_literal: true

require "rails_helper"

describe SearchDocument do
  subject(:search_document) { build(:invite) }

  around do |example|
    I18n.with_locale(:nb) do
      example.run
    end
  end

  describe ".search" do
    def query(str)
      described_class.search(str, locale: locale).results
    end

    let(:locale) { :en }

    describe "when searching name" do
      let!(:page) { create(:page, locale: locale, name: "foobar walking") }

      it "supports trigram similarity matching" do
        expect(query("fooobar")).to include(page)
      end
    end

    describe "when searching body in english" do
      let!(:page) { create(:page, locale: locale, body: "foobar walking") }

      it "returns the result" do
        expect(query("foobar")).to include(page)
      end

      it "supports prefix searches" do
        expect(query("foob")).to include(page)
      end

      it "does not support infix searches" do
        expect(query("bar")).not_to include(page)
      end

      it "ignores stopwords" do
        expect(query("the foobar")).to include(page)
      end

      it "performs stemming" do
        expect(query("walked")).to include(page)
      end

      it "does not support trigram similarity matching" do
        expect(query("fooobar")).not_to include(page)
      end

      it "localizes the result" do
        expect(query("foobar").first.locale).to eq("en")
      end
    end

    describe "when searching body in norwegian" do
      let(:locale) { :nb }
      let!(:page) { create(:page, locale: locale, body: "løsningen") }

      it "ignores accents" do
        expect(query("losningen")).to include(page)
      end

      it "ignores stopwords" do
        expect(query("en løsning")).to include(page)
      end

      it "performs stemming" do
        expect(query("løsninger")).to include(page)
      end

      it "localizes the result" do
        expect(query("løsningen").first.locale).to eq("nb")
      end
    end

    describe "searching without locale" do
      subject(:results) { described_class.search("example").results }

      let!(:en_page) { create(:page, locale: :en, name: "example") }
      let!(:nb_page) { create(:page, locale: :nb, name: "example") }

      it "searches the current locale" do
        expect(results).to include(nb_page)
      end

      it "does not search other locales" do
        expect(results).not_to include(en_page)
      end
    end
  end
end
