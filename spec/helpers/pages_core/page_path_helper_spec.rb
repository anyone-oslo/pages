require "spec_helper"

RSpec.describe PagesCore::PagePathHelper, type: :helper do
  let(:parent_page) { create(:page, locale: "nb", name: "Category") }
  let(:page) do
    create(:page, locale: "nb", name: "Product", parent: parent_page)
  end

  before { PagesCore.config.pages_path_scope = nil }

  describe "#page_path" do
    subject { helper.page_path("nb", page) }

    context "without page_path_scope" do
      context "when page has a page path" do
        context "and localizations are disabled" do
          before { PagesCore.config.localizations = :disabled }
          it { is_expected.to eq("/category/product") }
        end

        context "and localizations are enabled" do
          before { PagesCore.config.localizations = :enabled }
          it { is_expected.to eq("/nb/category/product") }
        end
      end

      context "when page doesn't have a page path" do
        before { page.path_segment = "" }
        it { is_expected.to eq("/nb/pages/#{page.id}-Product") }
      end
    end

    context "with page_path_scope" do
      before { PagesCore.config.pages_path_scope = "scope" }

      context "when page has a page path" do
        context "and localizations are disabled" do
          before { PagesCore.config.localizations = :disabled }
          it { is_expected.to eq("/scope/category/product") }
        end

        context "and localizations are enabled" do
          before { PagesCore.config.localizations = :enabled }
          it { is_expected.to eq("/scope/nb/category/product") }
        end
      end
    end
  end

  describe "#page_url" do
    subject { helper.page_url("nb", page) }

    context "when page has a page path" do
      context "and localizations are disabled" do
        before { PagesCore.config.localizations = :disabled }
        it { is_expected.to eq("http://test.host/category/product") }
      end

      context "and localizations are enabled" do
        before { PagesCore.config.localizations = :enabled }
        it { is_expected.to eq("http://test.host/nb/category/product") }
      end
    end

    context "when page doesn't have a page path" do
      before { page.path_segment = "" }
      it { is_expected.to eq("http://test.host/nb/pages/#{page.id}-Product") }
    end
  end
end
