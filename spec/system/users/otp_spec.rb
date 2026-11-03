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
    let(:code) { ROTP::TOTP.new(user.otp_secret).now }

    before do
      click_on "Disable"
      Timecop.travel(30.seconds.from_now)
      fill_in "6 digit code or recovery code", with: code
      click_on "Disable 2FA"
    end

    after { Timecop.return }

    specify { expect(page).to(have_text("2FA has been disabled")) }
    specify { expect(page).to(have_text("Enable 2FA")) }

    context "with a recovery code" do
      let(:code) { "recovery-code-1" }

      specify { expect(page).to(have_text("2FA has been disabled")) }
    end

    context "with an invalid code" do
      let(:code) { "invalid" }

      specify { expect(page).to(have_text("Invalid 2FA code")) }
      specify { expect(user.reload.otp_enabled?).to be(true) }
    end
  end
end
