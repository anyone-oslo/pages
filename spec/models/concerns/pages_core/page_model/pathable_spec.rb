# frozen_string_literal: true

require "rails_helper"

describe PagesCore::PageModel::Pathable, type: :model do
  subject { page }

  let(:page) { create(:page, locale: "nb") }

  it { is_expected.to allow_value("").for(:path_segment) }
  it { is_expected.to allow_value("føø-bar_123").for(:path_segment) }
  it { is_expected.not_to allow_value("with space").for(:path_segment) }
  it { is_expected.not_to allow_value("bang!").for(:path_segment) }
  it { is_expected.not_to allow_value("pages").for(:path_segment) }

  describe "auto-generated path segment" do
    subject { page.path_segment }

    let(:page_name) { "ØØ Test 123!" }
    let(:path_segment) { "oo-test-123" }
    let(:page) { create(:page, locale: "nb", name: page_name) }

    context "when defaulting" do
      it { is_expected.to eq(path_segment) }
    end

    context "when colliding with an existing route" do
      let(:page_name) { "Pages" }
      let(:path_segment) { "pages" }

      it { is_expected.to eq("#{path_segment}-#{page.id}") }
    end

    context "with existing path segment" do
      let(:page) { create(:page, locale: "nb", name: page_name) }

      before { create(:page, locale: "nb", name: page_name) }

      it { is_expected.to eq("#{path_segment}-#{page.id}") }
    end

    context "with existing path segment elsewhere" do
      let(:page) { create(:page, locale: "nb", name: page_name) }

      before do
        create(:page, locale: "nb", name: page_name, parent: create(:page))
      end

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

      it { is_expected.to be(true) }
    end

    context "when page has a parent without path segment" do
      let(:parent) { create(:page, locale: "en", name: "") }
      let(:page) { create(:page, locale: "en", parent: parent) }

      it { is_expected.to be(false) }
    end

    context "when page has a parent with path segment" do
      let(:parent) { create(:page, locale: "en", name: "Products") }
      let(:page) { create(:page, locale: "en", parent: parent) }

      it { is_expected.to be(true) }
    end
  end

  describe "#full_path?" do
    subject { page3.full_path? }

    let(:page1) { create(:page, locale: "en", name: "Products") }
    let(:page2) { create(:page, locale: "en", name: "Category", parent: page1) }
    let(:page3) { create(:page, locale: "en", name: "My thing", parent: page2) }

    context "when all parents have path segments" do
      it { is_expected.to be(true) }
    end

    context "when a parent is missing a path segment" do
      let(:page1) { create(:page, locale: "en", name: "") }

      it { is_expected.to be(false) }
    end
  end

  describe "#full_path" do
    subject { page3.full_path }

    let(:page1) { create(:page, locale: "en", name: "Products") }
    let(:page2) { create(:page, locale: "en", name: "Category", parent: page1) }
    let(:page3) { create(:page, locale: "en", name: "My thing", parent: page2) }
    let(:page4) { create(:page, locale: "en", name: "Other products") }

    context "when all parents have path segments" do
      it { is_expected.to eq("products/category/my-thing") }
    end

    context "when a parent is missing a path segment" do
      let(:page1) { create(:page, locale: "en", name: "") }

      it { is_expected.to be_nil }
    end

    context "when a parent is moved" do
      before { page2.update(parent: page4) }

      it { is_expected.to eq("other-products/category/my-thing") }
    end
  end
end
