# encoding: utf-8

require "rails_helper"

describe Autopublisher do
  describe ".run!" do
    let!(:future) { create(:page, published_at: (Time.now + 1.day)) }
    let!(:past) { create(:page, published_at: (Time.now - 1.day)) }
    before { past.update_column(:autopublish, true) }

    it "should autopublish the due pages" do
      Autopublisher.run!
      expect(Page.where(autopublish: true)).to match_array([future])
    end

    it "should schedule another run" do
      Autopublisher.run!
      expect(PagesCore::AutopublishJob).to have_been_enqueued
    end
  end

  describe ".queue!" do
    subject { Autopublisher.queue! }

    context "with future pages" do
      let!(:future) { create(:page, published_at: (Time.now + 1.day)) }
      it "should schedule a run" do
        expect(PagesCore::AutopublishJob).to have_been_enqueued
      end
    end

    context "without future pages" do
      it "should not schedule a run" do
        expect(PagesCore::AutopublishJob).not_to have_been_enqueued
      end
    end
  end
end
