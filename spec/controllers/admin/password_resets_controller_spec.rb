# frozen_string_literal: true

require "rails_helper"

describe Admin::PasswordResetsController, type: :controller do
  let(:user) { create(:user) }
  let(:password_reset_token) { create(:password_reset_token) }
  let(:expired_password_reset_token) do
    create(:password_reset_token, expires_at: 2.days.ago)
  end

  describe "POST create" do
    context "with an existing user" do
      let(:token_url) do
        admin_password_reset_with_token_url(
          assigns(:password_reset_token).id,
          assigns(:password_reset_token).token
        )
      end

      before { post :create, params: { username: user.email } }

      it { is_expected.to redirect_to(login_admin_users_url) }

      it "sets the flash" do
        expect(flash[:notice]).to match(
          /An email with further instructions has been sent/
        )
      end

      it "assigns the user" do
        expect(assigns(:user)).to be_a(User)
      end

      it "assigns the password reset token" do
        expect(assigns(:password_reset_token)).to be_a(PasswordResetToken)
      end

      it "emails the user" do
        expect(last_email.to).to eq([user.email])
      end

      it "sends the URL" do
        expect(last_email.body.encoded).to(match(token_url))
      end
    end

    context "with a non-existant user" do
      before { post :create, params: { username: "none@example.com" } }

      it { is_expected.to redirect_to(login_admin_users_url) }

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
      before do
        get(
          :show,
          params: {
            id: password_reset_token.id,
            token: password_reset_token.token
          }
        )
      end

      it { is_expected.to respond_with(:success) }
      it { is_expected.to render_template(:show) }

      it "assigns the user" do
        expect(assigns(:user)).to be_a(User)
      end

      it "assigns the password reset token" do
        expect(assigns(:password_reset_token)).to be_a(PasswordResetToken)
      end
    end

    context "without a valid token" do
      before { get :show, params: { id: password_reset_token.id } }

      it { is_expected.to redirect_to(login_admin_users_url) }

      it "sets the flash" do
        expect(flash.now[:notice]).to match(/Invalid password reset request/)
      end
    end

    context "with an expired token" do
      before do
        get(
          :show,
          params: {
            id: expired_password_reset_token.id,
            token: expired_password_reset_token.token
          }
        )
      end

      it { is_expected.to redirect_to(login_admin_users_url) }

      it "assigns the password reset token" do
        expect(assigns(:password_reset_token)).to be_a(PasswordResetToken)
      end

      it "sets the flash" do
        expect(flash.now[:notice]).to match(
          /Your password reset link has expired/
        )
      end

      it "destroys the token" do
        expect(assigns(:password_reset_token).destroyed?).to eq(true)
      end
    end

    context "with a non-existant token" do
      before { get :show, params: { id: 123, token: "456" } }

      it { is_expected.to redirect_to(login_admin_users_url) }

      it "sets the flash" do
        expect(flash.now[:notice]).to match(/Invalid password reset request/)
      end
    end
  end

  describe "PUT update" do
    context "with valid data" do
      before do
        put(:update,
            params: {
              id: password_reset_token.id,
              token: password_reset_token.token,
              user: { password: "new password",
                      confirm_password: "new password" }
            })
      end

      it { is_expected.to redirect_to(login_admin_users_url) }

      it "sets the flash" do
        expect(flash.now[:notice]).to match(/Your password has been changed/)
      end

      it "assigns the user" do
        expect(assigns(:user)).to be_a(User)
      end

      it "logs the user in" do
        expect(session[:current_user_id]).to eq(password_reset_token.user.id)
      end

      it "destroys the token" do
        expect(assigns(:password_reset_token).destroyed?).to eq(true)
      end
    end

    context "without valid data" do
      before do
        put(
          :update,
          params: {
            id: password_reset_token.id,
            token: password_reset_token.token,
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

      it "assigns the password reset token" do
        expect(assigns(:password_reset_token)).to be_a(PasswordResetToken)
      end

      it "does not destroy the token" do
        expect(assigns(:password_reset_token).destroyed?).to eq(false)
      end
    end

    context "without a valid token" do
      before do
        put :update,
            params: {
              id: password_reset_token.id,
              user: {
                password: "new password",
                confirm_password: "new password"
              }
            }
      end

      it { is_expected.to redirect_to(login_admin_users_url) }

      it "sets the flash" do
        expect(flash.now[:notice]).to match(/Invalid password reset request/)
      end
    end

    context "with an expired token" do
      before do
        put :update,
            params: {
              id: expired_password_reset_token.id,
              token: expired_password_reset_token.token,
              user: {
                password: "new password",
                confirm_password: "new password"
              }
            }
      end

      it { is_expected.to redirect_to(login_admin_users_url) }

      it "assigns the password reset token" do
        expect(assigns(:password_reset_token)).to be_a(PasswordResetToken)
      end

      it "sets the flash" do
        expect(flash.now[:notice]).to match(
          /Your password reset link has expired/
        )
      end

      it "destroys the token" do
        expect(assigns(:password_reset_token).destroyed?).to eq(true)
      end
    end
  end
end
