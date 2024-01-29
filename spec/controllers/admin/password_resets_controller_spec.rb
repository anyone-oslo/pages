# frozen_string_literal: true

require "rails_helper"

describe Admin::PasswordResetsController do
  def message_verifier
    Rails.application.message_verifier(:password_reset)
  end

  let(:user) { create(:user) }
  let(:valid_token) { message_verifier.generate({ id: user.id }) }
  let(:expired_token) do
    message_verifier.generate({ id: user.id }, expires_at: 2.days.ago)
  end

  describe "POST create" do
    context "with an existing user" do
      before do
        perform_enqueued_jobs do
          post :create, params: { email: user.email }
        end
      end

      it { is_expected.to redirect_to(admin_login_url) }

      it "sets the flash" do
        expect(flash[:notice]).to match(
          /An email with further instructions has been sent/
        )
      end

      it "assigns the user" do
        expect(assigns(:user)).to be_a(User)
      end

      it "emails the user" do
        expect(last_email.to).to eq([user.email])
      end

      it "sends the URL" do
        expect(last_email.body.encoded).to(match("admin/password_reset"))
      end
    end

    context "with a non-existant user" do
      before { post :create, params: { email: "none@example.com" } }

      it { is_expected.to redirect_to(admin_login_url) }

      it "does not assign the password reset token" do
        expect(assigns(:password_reset_token)).to be_nil
      end

      it "sets the flash" do
        expect(flash[:notice]).to match(
          /Couldn't find a user with that email address/
        )
      end
    end
  end

  describe "GET show" do
    context "with a valid token" do
      before { get(:show, params: { token: valid_token }) }

      it { is_expected.to respond_with(:success) }
      it { is_expected.to render_template(:show) }

      it "assigns the user" do
        expect(assigns(:user)).to be_a(User)
      end
    end

    context "without a valid token" do
      before { get :show, params: {} }

      it { is_expected.to redirect_to(new_admin_password_reset_url) }

      it "sets the flash" do
        expect(flash.now[:notice]).to(
          eq(I18n.t("pages_core.password_reset.invalid_request"))
        )
      end
    end

    context "with an expired token" do
      before { get(:show, params: { token: expired_token }) }

      it { is_expected.to redirect_to(new_admin_password_reset_url) }

      it "sets the flash" do
        expect(flash.now[:notice]).to(
          eq(I18n.t("pages_core.password_reset.invalid_request"))
        )
      end
    end

    context "with a non-existant token" do
      before { get :show, params: { token: "456" } }

      it { is_expected.to redirect_to(new_admin_password_reset_url) }

      it "sets the flash" do
        expect(flash.now[:notice]).to(
          eq(I18n.t("pages_core.password_reset.invalid_request"))
        )
      end
    end
  end

  describe "PUT update" do
    context "with valid data" do
      before do
        put(:update,
            params: {
              token: valid_token,
              user: { password: "new password",
                      confirm_password: "new password" }
            })
      end

      it { is_expected.to redirect_to(admin_login_url) }

      it "sets the flash" do
        expect(flash.now[:notice]).to match(/Your password has been changed/)
      end

      it "assigns the user" do
        expect(assigns(:user)).to be_a(User)
      end

      it "logs the user in" do
        expect(session[:current_user_id]).to eq(user.id)
      end
    end

    context "without valid data" do
      before do
        put(
          :update,
          params: {
            token: valid_token,
            user: {
              password: "new password",
              confirm_password: "wrong password"
            }
          }
        )
      end

      it { is_expected.to respond_with(:success) }
      it { is_expected.to render_template(:show) }

      it "assigns the user" do
        expect(assigns(:user)).to be_a(User)
      end
    end

    context "without a valid token" do
      before do
        put :update,
            params: {
              user: {
                password: "new password",
                confirm_password: "new password"
              }
            }
      end

      it { is_expected.to redirect_to(new_admin_password_reset_url) }

      it "sets the flash" do
        expect(flash.now[:notice]).to(
          eq(I18n.t("pages_core.password_reset.invalid_request"))
        )
      end
    end

    context "with an expired token" do
      before do
        put :update,
            params: {
              token: expired_token,
              user: {
                password: "new password",
                confirm_password: "new password"
              }
            }
      end

      it { is_expected.to redirect_to(new_admin_password_reset_url) }

      it "sets the flash" do
        expect(flash.now[:notice]).to(
          eq(I18n.t("pages_core.password_reset.invalid_request"))
        )
      end
    end
  end
end
