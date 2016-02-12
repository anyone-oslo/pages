# encoding: utf-8

require "rails_helper"

describe PagesCore::PathablePage, type: :model do
  let(:page) { create(:page, locale: "nb") }

  subject { page }

  it { is_expected.to allow_value("").for(:path_segment) }
  it { is_expected.to allow_value("føø-bar_123").for(:path_segment) }
  it { is_expected.not_to allow_value("with space").for(:path_segment) }
  it { is_expected.not_to allow_value("bang!").for(:path_segment) }
  it { is_expected.not_to allow_value("pages").for(:path_segment) }

  describe "auto-generated path segment" do
    let(:page_name) { "ØØ Test 123!" }
    let(:path_segment) { "øø-test-123" }
    let(:page) { create(:page, locale: "nb", name: page_name) }

    subject { page.path_segment }

    context "defaulting" do
      it { is_expected.to eq(path_segment) }
    end

    context "when colliding with an existing route" do
      let(:page_name) { "Pages" }
      let(:path_segment) { "pages" }
      it { is_expected.to eq("#{path_segment}-#{page.id}") }
    end

    context "with existing path segment" do
      let!(:existing_page) { create(:page, locale: "nb", name: page_name) }
      let!(:page) { create(:page, locale: "nb", name: page_name) }

      it { is_expected.to eq("#{path_segment}-#{page.id}") }
    end

    context "with existing path segment elsewhere" do
      let!(:existing_page) do
        create(:page, locale: "nb", name: page_name, parent: create(:page))
      end
      let!(:page) { create(:page, locale: "nb", name: page_name) }

      it { is_expected.to eq(path_segment) }
    end

    context "when page is deleted" do
      before { page.update(status: 4) }
      it { is_expected.to eq("") }
    end

    context "when page name is changed" do
      before { page.update(name: "New name") }
      it { is_expected.to eq(path_segment) }
    end
  end

  describe "#pathable?" do
    subject { page.pathable? }

    context "when page has no parents" do
      let(:page) { create(:page) }
      it { is_expected.to eq(true) }
    end

    context "when page has a parent without path segment" do
      let(:parent) { create(:page, locale: "en", name: "") }
      let(:page) { create(:page, locale: "en", parent: parent) }

      it { is_expected.to eq(false) }
    end

    context "when page has a parent with path segment" do
      let(:parent) { create(:page, locale: "en", name: "Products") }
      let(:page) { create(:page, locale: "en", parent: parent) }

      it { is_expected.to eq(true) }
    end
  end

  describe "#full_path?" do
    let(:page1) { create(:page, locale: "en", name: "Products") }
    let(:page2) { create(:page, locale: "en", name: "Category", parent: page1) }
    let(:page3) { create(:page, locale: "en", name: "My thing", parent: page2) }

    subject { page3.full_path? }

    context "when all parents have path segments" do
      it { is_expected.to eq(true) }
    end

    context "when a parent is missing a path segment" do
      let(:page1) { create(:page, locale: "en", name: "") }
      it { is_expected.to eq(false) }
    end
  end

  describe "#full_path" do
    let(:page1) { create(:page, locale: "en", name: "Products") }
    let(:page2) { create(:page, locale: "en", name: "Category", parent: page1) }
    let(:page3) { create(:page, locale: "en", name: "My thing", parent: page2) }
    let(:page4) { create(:page, locale: "en", name: "Other products") }

    subject { page3.full_path }

    context "when all parents have path segments" do
      it { is_expected.to eq("products/category/my-thing") }
    end

    context "with argument" do
      subject { page3.full_path("argument") }
      it { is_expected.to eq("products/category/argument") }
    end

    context "when a parent is missing a path segment" do
      let(:page1) { create(:page, locale: "en", name: "") }
      it { is_expected.to eq(nil) }
    end

    context "when a parent is moved" do
      before { page2.update(parent: page4) }
      it { is_expected.to eq("other-products/category/my-thing") }
    end
  end
end
