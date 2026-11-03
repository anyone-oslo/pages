# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Account recovery" do
  def request_recovery(email)
    perform_enqueued_jobs do
      visit admin_login_path
      click_on "Help! I forgot my password!"
      fill_in "Email address", with: email
      click_on "Send"
    end
  end

  let(:user) { create(:user) }
  let(:hosts) { [] }
  let(:mailer_url_options) { { host: "mail.example.com" } }

  before do
    allow(Rails.application.config).to receive(:hosts).and_return(hosts)
    allow(AdminMailer).to(
      receive(:default_url_options).and_return(mailer_url_options)
    )
  end

  describe "Requesting a recovery" do
    let(:email) { user.email }

    before { request_recovery(email) }

    specify do
      expect(page).to(
        have_text(I18n.t("pages_core.account_recovery.sent").strip)
      )
    end

    specify { expect(last_email.to).to eq([user.email]) }

    specify do
      expect(last_email.body.encoded).to(
        include("https://mail.example.com/admin/account_recovery/")
      )
    end

    context "when user does not exist" do
      let(:email) { "none@example.com" }

      specify { expect(last_email).to be_nil }

      specify do
        expect(page).to(
          have_text(I18n.t("pages_core.account_recovery.sent").strip)
        )
      end
    end

    context "when user is deactivated" do
      let(:user) { create(:user, :deactivated) }

      specify do
        expect(page).to(
          have_text(I18n.t("pages_core.account_recovery.sent").strip)
        )
      end

      specify { expect(last_email).to be_nil }
    end

    context "when host authorization is enabled" do
      let(:hosts) { ["www.example.com"] }

      specify do
        expect(last_email.body.encoded).to(
          include("http://www.example.com/admin/account_recovery/")
        )
      end
    end

    context "when the mailer has a protocol and port" do
      let(:mailer_url_options) do
        { host: "mail.example.com", port: 8443, protocol: "https" }
      end

      specify do
        expect(last_email.body.encoded).to(
          include("https://mail.example.com:8443/admin/account_recovery/")
        )
      end
    end
  end

  describe "Requesting a recovery without a known host" do
    let(:mailer_url_options) { {} }

    specify do
      expect { request_recovery(user.email) }.to raise_error(/config.hosts/)
    end
  end

  describe "Completing a recovery" do
    let(:token) { user.password_reset_token }

    before do
      visit admin_account_recovery_with_token_path(token)
    end

    context "when token is invalid" do
      let(:token) { "invalid" }

      specify { expect(page).to have_text("This link is no longer valid") }
    end

    context "when token has expired" do
      let(:token) do
        Timecop.freeze(25.hours.ago) { user.password_reset_token }
      end

      specify { expect(page).to have_text("This link is no longer valid") }
    end

    context "when token has already been used" do
      before do
        fill_in "Password", with: "new password"
        fill_in "Password confirmation", with: "new password"
        click_on "Change password"
        visit admin_account_recovery_with_token_path(token)
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

    context "when user is deactivated" do
      let(:user) { create(:user, :deactivated) }

      specify do
        expect(page).to have_text(I18n.t("pages_core.invalid_login").strip)
      end

      specify { expect(page).to have_no_button("Change password") }
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
