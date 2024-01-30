# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Account recovery" do
  def message_verifier
    Rails.application.message_verifier(:account_recovery)
  end

  let(:user) { create(:user) }

  describe "Requesting a recovery" do
    let(:email) { user.email }

    before do
      perform_enqueued_jobs do
        visit admin_login_path
        click_on "Help! I forgot my password!"
        fill_in "Email address", with: email
        click_on "Send"
      end
    end

    specify do
      expect(page).to(
        have_text("An email with further instructions has been sent")
      )
    end

    specify { expect(last_email.to).to eq([user.email]) }

    context "when user does not exist" do
      let(:email) { "none@example.com" }

      specify do
        expect(page).to(
          have_text("Couldn't find a user with that email address")
        )
      end
    end
  end

  describe "Completing a recovery" do
    let(:token) { message_verifier.generate({ id: user.id }) }

    before do
      visit admin_account_recovery_with_token_path(token)
    end

    context "when token is invalid" do
      let(:token) { "invalid" }

      specify { expect(page).to have_text("This link is no longer valid") }
    end

    context "when token has expired" do
      let(:token) do
        message_verifier.generate({ id: user.id }, expires_at: 2.days.ago)
      end

      specify { expect(page).to have_text("This link is no longer valid") }
    end

    context "without 2FA" do
      before do
        fill_in "Password", with: "new password"
        fill_in "Password confirmation", with: "new password"
        click_on "Change password"
      end

      specify { expect(page).to have_text("Your password has been changed") }
    end

    context "with mismatched password" do
      before do
        fill_in "Password", with: "new password"
        fill_in "Password confirmation", with: "wrong password"
        click_on "Change password"
      end

      specify do
        expect(page).to have_text("Password confirmation doesn't match")
      end
    end

    context "when using OTP" do
      let(:user) { create(:user, :otp) }

      before do
        fill_in "Password", with: "new password"
        fill_in "Password confirmation", with: "new password"
        fill_in("6 digit code or recovery code",
                with: ROTP::TOTP.new(user.otp_secret).now)
        click_on "Change password"
      end

      specify { expect(page).to have_text("Your password has been changed") }
    end

    context "when using recovery code" do
      let(:user) { create(:user, :otp) }

      before do
        fill_in "Password", with: "new password"
        fill_in "Password confirmation", with: "new password"
        fill_in("6 digit code or recovery code",
                with: "recovery-code-1")
        click_on "Change password"
      end

      specify { expect(page).to have_text("Your password has been changed") }

      specify do
        visit edit_admin_user_path(user.id)
        expect(page).to have_text("one recovery code remaining")
      end
    end

    context "when using an invalid code" do
      let(:user) { create(:user, :otp) }

      before do
        fill_in "Password", with: "new password"
        fill_in "Password confirmation", with: "new password"
        fill_in("6 digit code or recovery code", with: "invalid")
        click_on "Change password"
      end

      specify do
        expect(page).to have_text(I18n.t("pages_core.otp.invalid_code"))
      end
    end
  end
end
