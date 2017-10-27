require "rails_helper"

describe Autopublisher do
  describe ".run!" do
    let!(:future) { create(:page, published_at: (Time.now.utc + 1.day)) }
    let!(:past) { create(:page, published_at: (Time.now.utc - 1.day)) }
    before { past.update(autopublish: true) }

    it "should autopublish the due pages" do
      Autopublisher.run!
      expect(Page.where(autopublish: true)).to match_array([future])
    end

    it "should schedule another run" do
      expect { Autopublisher.run! }.to(
        have_enqueued_job(PagesCore::AutopublishJob)
      )
    end
  end

  describe ".queue!" do
    context "with future pages" do
      let!(:future) { create(:page, published_at: (Time.now.utc + 1.day)) }
      it "should schedule a run" do
        expect { Autopublisher.queue! }.to(
          have_enqueued_job(PagesCore::AutopublishJob)
        )
      end
    end

    context "without future pages" do
      it "should not schedule a run" do
        expect { Autopublisher.queue! }.not_to(
          have_enqueued_job(PagesCore::AutopublishJob)
        )
      end
    end
  end
end
