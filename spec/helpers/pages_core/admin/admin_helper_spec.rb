require "rails_helper"

RSpec.describe PagesCore::Admin::AdminHelper, type: :helper do
  describe "#add_body_class" do
    before { helper.add_body_class("foo") }

    it "should add the class" do
      expect(helper.body_classes).to include("foo")
    end
  end

  describe "#body_classes" do
    let(:classes) { ["action_view/test_case/test_controller"] }
    subject { helper.body_classes }

    it { is_expected.to eq(classes) }

    context "when notice has been set" do
      before { helper.flash[:notice] = "Notice" }
      it { is_expected.to eq(classes + ["with_notice"]) }
    end
  end

  describe "#editable_dynamic_image_tag" do
    let(:image) { create(:image) }
    subject { helper.editable_dynamic_image_tag(image) }

    it { is_expected.to match("<a class=\"editableImage\"") }
    it { is_expected.to match("<img alt=\"Image\" src=\"/dynamic_images/") }
  end

  describe "#content_tab" do
    let(:tabs) { helper.instance_variable_get(:@content_tabs) }
    subject { helper.content_tab(:foo) { "Content" } }

    it "should render the tab" do
      expect(subject).to eq(
        "<div class=\"content_tab\" id=\"content-tab-foo\">Content</div>"
      )
    end

    it "should store the tab" do
      subject
      expect(tabs.first[:name]).to eq("Foo")
      expect(tabs.first[:key]).to eq("foo")
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
      it "should have been deprecated" do
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
      it "should have been deprecated" do
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
      it "should have been deprecated" do
        allow(ActiveSupport::Deprecation).to receive(:warn)
        helper.page_title("Foo")
        expect(ActiveSupport::Deprecation).to have_received(:warn)
      end
    end
  end
end
