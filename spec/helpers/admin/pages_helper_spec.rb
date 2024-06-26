# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::PagesHelper do
  let(:page) { build(:page) }

  describe "#page_name" do
    subject { helper.page_name(page) }

    let(:parent) { build(:page) }
    let(:page) { build(:page, parent:) }

    context "without parents" do
      it { is_expected.to eq(page.name) }
    end

    context "with parents" do
      subject { helper.page_name(page, include_parents: true) }

      it { is_expected.to eq("#{parent.name} » #{page.name}") }
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
    subject { helper.publish_time(timestamp) }

    before { Timecop.freeze(Time.zone.parse("2016-02-10 14:10")) }

    after { Timecop.return }

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
