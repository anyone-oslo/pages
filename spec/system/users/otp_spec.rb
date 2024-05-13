# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Two-factor authentication" do
  let(:user) { create(:user) }

  before do
    login_as(user)
    click_on "Users"
    click_on "Edit"
  end

  context "when enabling 2FA" do
    let(:otp) { ROTP::TOTP.new(find(".otp-secret").text).now }

    before { click_on "Enable 2FA" }

    specify { expect(page).to(have_text("Scan the QR-code")) }

    context "when confirming OTP" do
      before do
        fill_in "6 digit code", with: otp
        click_on "Verify"
      end

      specify { expect(page).to have_text("Two-factor authentication enabled") }
    end

    context "when entering the wrong OTP" do
      before do
        fill_in "6 digit code", with: "123123"
        click_on "Verify"
      end

      specify { expect(page).to have_text("Invalid 2FA code") }
    end
  end

  context "when disabling 2FA" do
    let(:user) { create(:user, :otp) }

    before { click_on "Disable" }

    specify { expect(page).to(have_text("2FA has been disabled")) }
    specify { expect(page).to(have_text("Enable 2FA")) }
  end
end
