# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Logging in" do
  let(:user) { create(:user) }
  let(:otp_code) { ROTP::TOTP.new(user.otp_secret).now }

  def enter_otp(code)
    fill_in "6 digit code", with: code
    click_on "Verify"
  end

  it "User logs in" do
    login_as(user)
    expect(page).to(have_text("Log out"))
  end

  it "User logs out" do
    login_as(user)
    click_on("Log out")
    expect(page).to(have_no_text("Log out"))
  end

  it "User is deactivated while logged in" do
    login_as(user)
    user.update(activated: false)
    visit admin_default_path
    expect(page).to(have_button("Sign in"))
  end

  context "when user is deactivated" do
    let(:user) { create(:user, :deactivated) }

    it "User is refused" do
      login_as(user)
      expect(page).to(have_text(I18n.t("pages_core.invalid_login").strip))
    end

    it "User is not logged in" do
      login_as(user)
      visit admin_default_path
      expect(page).to(have_button("Sign in"))
    end
  end

  context "when OTP is enabled" do
    let(:user) { create(:user, :otp) }

    it "User logs in" do
      login_as(user)
      expect(page).to(have_text("Log out"))
    end

    context "when user is deactivated" do
      let(:user) { create(:user, :otp, :deactivated) }

      it "User is refused at the password step" do
        login_with(user.email, user.password)
        expect(page).to(have_text(I18n.t("pages_core.invalid_login").strip))
      end

      it "User is not asked for a 2FA code" do
        login_with(user.email, user.password)
        expect(page).to(have_no_field("6 digit code"))
      end
    end

    it "User enters an invalid 2FA code" do
      login_with(user.email, user.password, otp: "000000")
      expect(page).to(have_text(I18n.t("pages_core.otp.invalid_code")))
    end

    it "User enters an invalid 2FA code, then a valid one" do
      login_with(user.email, user.password, otp: "000000")
      enter_otp(otp_code)
      expect(page).to(have_text("Log out"))
    end

    it "User waits too long before entering the 2FA code" do
      login_with(user.email, user.password)
      Timecop.travel(11.minutes.from_now) { enter_otp(otp_code) }
      expect(page).to(have_text(I18n.t("pages_core.invalid_login").strip))
    end

    it "User's password changes before entering the 2FA code" do
      login_with(user.email, user.password)
      user.update(password: "new password", password_confirmation: "new password")
      enter_otp(otp_code)
      expect(page).to(have_text(I18n.t("pages_core.invalid_login").strip))
    end
  end
end
