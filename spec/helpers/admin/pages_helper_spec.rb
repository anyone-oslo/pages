require "rails_helper"

RSpec.describe Admin::PagesHelper, type: :helper do
  let(:page) { build(:page) }

  describe "#available_templates_for_select" do
    subject { helper.available_templates_for_select }

    let(:template_options) { [%w([Default] index), %w[Home home]] }

    it { is_expected.to eq(template_options) }
  end

  describe "#file_embed_code" do
    subject { helper.file_embed_code(file) }

    let(:file) { create(:page_file) }

    it { is_expected.to eq("[file:#{file.id}]") }
  end

  describe "#page_name" do
    subject { helper.page_name(page) }

    let(:parent) { build(:page) }
    let(:page) { build(:page, parent: parent) }

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
    before { Timecop.freeze(Time.zone.parse("2016-02-10 14:10")) }
    after { Timecop.return }
    subject { helper.publish_time(timestamp) }

    context "when in a different year" do
      let(:timestamp) { Time.zone.parse("2013-03-12 12:13") }

      it { is_expected.to eq("on Mar 12 2013 at 12:13") }
    end

    context "when on a different date" do
      let(:timestamp) { Time.zone.parse("2016-03-12 12:13") }

      it { is_expected.to eq("on Mar 12 at 12:13") }
    end

    context "when on the same date" do
      let(:timestamp) { Time.zone.parse("2016-02-10 12:13") }

      it { is_expected.to eq("at 12:13") }
    end
  end
end
