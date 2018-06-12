require "rails_helper"

describe Autopublisher do
  describe ".run!" do
    let!(:future) { create(:page, published_at: (Time.now.utc + 1.day)) }
    let!(:past) { create(:page, published_at: (Time.now.utc - 1.day)) }

    before { past.update(autopublish: true) }

    it "autopublishes the due pages" do
      described_class.run!
      expect(Page.where(autopublish: true)).to match_array([future])
    end

    it "schedules another run" do
      expect { described_class.run! }.to(
        have_enqueued_job(PagesCore::AutopublishJob)
      )
    end
  end

  describe ".queue!" do
    context "with future pages" do
      before { create(:page, published_at: (Time.now.utc + 1.day)) }

      it "schedules a run" do
        expect { described_class.queue! }.to(
          have_enqueued_job(PagesCore::AutopublishJob)
        )
      end
    end

    context "without future pages" do
      it "does not schedule a run" do
        expect { described_class.queue! }.not_to(
          have_enqueued_job(PagesCore::AutopublishJob)
        )
      end
    end
  end
end
