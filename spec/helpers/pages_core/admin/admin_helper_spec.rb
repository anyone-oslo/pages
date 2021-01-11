# frozen_string_literal: true

require "rails_helper"

RSpec.describe PagesCore::Admin::AdminHelper, type: :helper do
  describe "#add_body_class" do
    before { helper.add_body_class("foo") }

    it "adds the class" do
      expect(helper.body_classes).to include("foo")
    end
  end

  describe "#body_classes" do
    subject { helper.body_classes }

    let(:classes) { [] }

    it { is_expected.to eq(classes) }

    context "when notice has been set" do
      before { helper.flash[:notice] = "Notice" }

      it { is_expected.to eq(classes + ["with_notice"]) }
    end
  end

  describe "#content_tab" do
    subject!(:tab) { helper.content_tab(:foo) { "Content" } }

    let(:tabs) { helper.instance_variable_get(:@content_tabs) }

    it "renders the tab" do
      expect(tab).to eq(
        "<div class=\"content_tab\" id=\"content-tab-foo\">Content</div>"
      )
    end

    it "stores the tab" do
      expect(tabs.first[:name]).to eq("Foo")
    end
  end

  describe "#link_separator" do
    subject { helper.link_separator }

    it { is_expected.to eq(" <span class=\"separator\">|</span> ") }
  end

  describe "page_description" do
    subject { helper.page_description }

    it { is_expected.to eq(nil) }

    context "when description has been set" do
      before { helper.page_description = "Foo" }

      it { is_expected.to eq("Foo") }
    end

    context "with arguments" do
      it "has been deprecated" do
        allow(ActiveSupport::Deprecation).to receive(:warn)
        helper.page_description("string", "class")
        expect(ActiveSupport::Deprecation).to have_received(:warn).twice
      end
    end
  end

  describe "page_description_links" do
    subject { helper.page_description_links }

    it { is_expected.to eq(nil) }

    context "when description links have been set" do
      before { helper.page_description_links = "Foo" }

      it { is_expected.to eq("Foo") }
    end

    context "with arguments" do
      it "has been deprecated" do
        allow(ActiveSupport::Deprecation).to receive(:warn)
        helper.page_description_links("Foo")
        expect(ActiveSupport::Deprecation).to have_received(:warn)
      end
    end
  end

  describe "page_title" do
    subject { helper.page_title }

    it { is_expected.to eq(nil) }

    context "when description has been set" do
      before { helper.page_title = "Foo" }

      it { is_expected.to eq("Foo") }
    end

    context "with arguments" do
      it "has been deprecated" do
        allow(ActiveSupport::Deprecation).to receive(:warn)
        helper.page_title("Foo")
        expect(ActiveSupport::Deprecation).to have_received(:warn)
      end
    end
  end
end
