require "rails_helper"

RSpec.describe Admin::PagesHelper, type: :helper do
  let(:page) { build(:page) }

  describe "#available_templates_for_select" do
    let(:template_options) { [%w([Default] index), %w[Home home]] }
    subject { helper.available_templates_for_select }

    it { is_expected.to eq(template_options) }
  end

  describe "#file_embed_code" do
    let(:file) { create(:page_file) }
    subject { helper.file_embed_code(file) }

    it { is_expected.to eq("[file:#{file.id}]") }
  end

  describe "#page_block_field" do
    let(:builder) { PagesCore::FormBuilder.new("page", page, helper, {}) }
    let(:subject) { helper.page_block_field(builder, name, options) }
    let(:name) { :name }
    let(:options) { { size: :small, title: "Page name" } }

    context "when size is a field" do
      let(:options) { { size: :field, title: "Page name" } }
      it "should render" do
        expect(subject).to eq(
          "<div class=\"field\"><label>Page name</label>" \
            "<input class=\"rich\" type=\"text\" " \
            "value=\"#{page.name}\" name=\"page[name]\" " \
            "id=\"page_name\" /></div>"
        )
      end
    end

    context "when size is small" do
      let(:options) { { size: :large, title: "Page name" } }
      it "should render" do
        expect(subject).to eq(
          "<div class=\"field\">" \
            "<label>Page name</label>" \
            "<textarea class=\"rich\" rows=\"15\" " \
            "name=\"page[name]\" id=\"page_name\">\n#{page.name}" \
            "</textarea></div>"
        )
      end
    end

    context "with description" do
      let(:options) do
        { size: :small,
          title: "Page name",
          description: "Description" }
      end
      it "should render" do
        expect(subject).to eq(
          "<div class=\"field\">" \
            "<label>Page name</label>" \
            "<p class=\"description\">Description</p>" \
            "<textarea class=\"rich\" rows=\"5\" " \
            "name=\"page[name]\" id=\"page_name\">\n#{page.name}" \
            "</textarea></div>"
        )
      end
    end
  end

  describe "#page_name" do
    let(:parent) { build(:page) }
    let(:page) { build(:page, parent: parent) }
    subject { helper.page_name(page) }

    context "without parents" do
      it { is_expected.to eq(page.name) }
    end

    context "with parents" do
      subject { helper.page_name(page, include_parents: true) }
      it { is_expected.to eq("#{parent.name} &raquo; #{page.name}") }
    end

    context "with fallback locale" do
      let(:page) { create(:page).localize(:es) }
      let(:unlocalized) { page.localize(I18n.default_locale) }
      it { is_expected.to eq("(#{unlocalized.name})") }
    end

    context "without name" do
      let(:page) { build(:page, name: "") }
      it { is_expected.to eq("(Untitled)") }
    end
  end

  describe "publish_time" do
    before { Timecop.freeze(DateTime.parse("2016-02-10 14:10").utc) }
    after { Timecop.return }
    subject { helper.publish_time(timestamp) }

    context "in a different year" do
      let(:timestamp) { DateTime.parse("2013-03-12 12:13").utc }
      it { is_expected.to eq("on Mar 12 2013 at 12:13") }
    end

    context "on a different date" do
      let(:timestamp) { DateTime.parse("2016-03-12 12:13").utc }
      it { is_expected.to eq("on Mar 12 at 12:13") }
    end

    context "on the same date" do
      let(:timestamp) { DateTime.parse("2016-02-10 12:13").utc }
      it { is_expected.to eq("at 12:13") }
    end
  end
end
