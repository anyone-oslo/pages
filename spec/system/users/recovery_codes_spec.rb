# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Recovery codes" do
  let(:user) { create(:user, :otp) }

  before do
    Timecop.travel(10.minutes.ago) { login_as(user) }
    click_on "Users"
    click_on "Edit"
  end

  specify { expect(page).to have_text("You have 2 recovery codes remaining") }

  context "when generating new codes" do
    before do
      click_on "Generate new codes"
      fill_in "6 digit code", with: ROTP::TOTP.new(user.otp_secret).now
      click_on "Verify"
    end

    specify { expect(page).to have_text("Recovery codes updated") }
    specify { expect(page).to have_css(".recovery-codes li") }

    specify do
      click_on "Users"
      click_on "Edit"
      expect(page).to have_text("You have 10 recovery codes remaining")
    end
  end
end
