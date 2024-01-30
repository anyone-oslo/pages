# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Logging in" do
  let(:user) { create(:user) }
  let(:otp_code) { ROTP::TOTP.new(user.otp_secret).now }

  it "User logs in" do
    login_as(user)
    expect(page).to(have_text("Log out"))
  end

  it "User logs out" do
    login_as(user)
    click_on("Log out")
    expect(page).to(have_no_text("Log out"))
  end

  context "when OTP is enabled" do
    let(:user) { create(:user, :otp) }

    it "User logs in" do
      login_as(user)
      expect(page).to(have_text("Log out"))
    end

    it "User enters an invalid 2FA code" do
      login_with(user.email, user.password, otp: "000000")
      expect(page).to(have_text(I18n.t("pages_core.otp.invalid_code")))
    end
  end
end
