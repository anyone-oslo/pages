# encoding: utf-8

require "spec_helper"

describe PagesCore::PathablePage do
  let(:page) { create(:page, locale: "nb") }

  subject { page }

  it { is_expected.to allow_value(nil).for(:path_segment) }
  it { is_expected.to allow_value("").for(:path_segment) }
  it { is_expected.to allow_value("føø-bar_123").for(:path_segment) }
  it { is_expected.not_to allow_value("with space").for(:path_segment) }
  it { is_expected.not_to allow_value("bang!").for(:path_segment) }

  describe "auto-generated path segment" do
    let(:page_name) { "ØØ Test 123!" }
    let(:page_segment) { "øø-test-123" }
    let(:page) { create(:page, locale: "nb", name: page_name) }

    subject { page.path_segment }

    context "defaulting" do
      it { is_expected.to eq(page_segment) }
    end

    context "with existing path segment" do
      let!(:existing_page) { create(:page, locale: "nb", name: page_name) }
      let!(:page) { create(:page, locale: "nb", name: page_name) }

      it { is_expected.to eq("#{page_segment}-#{page.id}") }
    end

    context "with existing path segment elsewhere" do
      let!(:existing_page) do
        create(:page, locale: "nb", name: page_name, parent: create(:page))
      end
      let!(:page) { create(:page, locale: "nb", name: page_name) }

      it { is_expected.to eq(page_segment) }
    end

    context "when page is deleted" do
      before { page.update(status: 4) }
      it { is_expected.to eq("") }
    end

    context "when page name is changed" do
      before { page.update(name: "New name") }
      it { is_expected.to eq(page_segment) }
    end
  end
end
