# frozen_string_literal: true

require "rails_helper"

describe Admin::AccountRecoveriesController do
  let(:user) { create(:user) }

  describe "POST create" do
    before do
      allow(AdminMailer).to(
        receive(:default_url_options).and_return(host: "mail.example.com")
      )
    end

    context "when the limit is reached" do
      before do
        3.times { post :create, params: { email: " #{user.email.upcase} " } }
        reset_email
        perform_enqueued_jobs { post :create, params: { email: user.email } }
      end

      it { is_expected.to redirect_to(new_admin_account_recovery_url) }

      it "sets the flash" do
        expect(flash[:notice]).to eq(I18n.t("pages_core.rate_limited"))
      end

      it "does not send an email" do
        expect(last_email).to be_nil
      end
    end

    context "when email is an array" do
      before do
        perform_enqueued_jobs do
          post :create, params: { email: [user.email, "x1@example.com"] }
        end
      end

      it "does not send an email" do
        expect(last_email).to be_nil
      end

      it "sets the flash" do
        expect(flash[:notice])
          .to eq(I18n.t("pages_core.account_recovery.sent"))
      end
    end

    context "when the limit is reached for another email" do
      before do
        3.times { post :create, params: { email: "other@example.com" } }
        perform_enqueued_jobs { post :create, params: { email: user.email } }
      end

      it "sends an email" do
        expect(last_email.to).to eq([user.email])
      end
    end
  end

  describe "PUT update" do
    context "when user is deactivated" do
      let(:user) { create(:user, :deactivated) }

      before do
        put :update, params: {
          token: user.password_reset_token,
          user: { password: "new password",
                  password_confirmation: "new password" }
        }
      end

      it { is_expected.to redirect_to(admin_login_url) }

      it "does not change the password" do
        expect(user.reload.authenticate("new password")).to be(false)
      end
    end
  end
end
