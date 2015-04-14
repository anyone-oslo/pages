require "spec_helper"

describe Admin::PasswordResetsController, type: :controller do
  let(:user) { create(:user) }
  let(:password_reset_token) { create(:password_reset_token) }
  let(:expired_password_reset_token) do
    create(:password_reset_token, expires_at: 2.days.ago)
  end

  describe "POST create" do
    context "with an existing user" do
      before { post :create, username: user.email }

      it { is_expected.to redirect_to(login_admin_users_url) }

      it "should set the flash" do
        expect(flash[:notice]).to match(
          /An email with further instructions has been sent/
        )
      end

      it "should assign the user" do
        expect(assigns(:user)).to be_a(User)
      end

      it "should assign the password reset token" do
        expect(assigns(:password_reset_token)).to be_a(PasswordResetToken)
      end

      it "should email the user" do
        expect(last_email.to).to eq([user.email])
        expect(last_email.body.encoded).to match(
          admin_password_reset_with_token_url(
            assigns(:password_reset_token).id,
            assigns(:password_reset_token).token
          )
        )
      end
    end

    context "with a non-existant user" do
      before { post :create, username: "none@example.com" }

      it { is_expected.to redirect_to(login_admin_users_url) }

      it "should not assign the password reset token" do
        expect(assigns(:password_reset_token)).to be_nil
      end

      it "should set the flash" do
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
          id: password_reset_token.id,
          token: password_reset_token.token
        )
      end

      it { is_expected.to respond_with(:success) }
      it { is_expected.to render_template(:show) }

      it "should assign the user" do
        expect(assigns(:user)).to be_a(User)
      end

      it "should assign the password reset token" do
        expect(assigns(:password_reset_token)).to be_a(PasswordResetToken)
      end
    end

    context "without a valid token" do
      before { get :show, id: password_reset_token.id }

      it { is_expected.to redirect_to(login_admin_users_url) }

      it "should set the flash" do
        expect(flash.now[:notice]).to match(/Invalid password reset request/)
      end
    end

    context "with an expired token" do
      before do
        get(
          :show,
          id: expired_password_reset_token.id,
          token: expired_password_reset_token.token
        )
      end

      it { is_expected.to redirect_to(login_admin_users_url) }

      it "should assign the password reset token" do
        expect(assigns(:password_reset_token)).to be_a(PasswordResetToken)
      end

      it "should set the flash" do
        expect(flash.now[:notice]).to match(
          /Your password reset link has expired/
        )
      end

      it "should destroy the token" do
        expect(assigns(:password_reset_token).destroyed?).to eq(true)
      end
    end

    context "with a non-existant token" do
      before { get :show, id: 123, token: "456" }

      it { is_expected.to redirect_to(login_admin_users_url) }

      it "should set the flash" do
        expect(flash.now[:notice]).to match(/Invalid password reset request/)
      end
    end
  end

  describe "PUT update" do
    context "with valid data" do
      before do
        put :update,
            id: password_reset_token.id,
            token: password_reset_token.token,
            user: { password: "new password", confirm_password: "new password" }
      end

      it { is_expected.to redirect_to(login_admin_users_url) }

      it "should set the flash" do
        expect(flash.now[:notice]).to match(/Your password has been changed/)
      end

      it "should assign the user" do
        expect(assigns(:user)).to be_a(User)
      end

      it "should log the user in" do
        expect(session[:current_user_id]).to eq(password_reset_token.user.id)
      end

      it "should destroy the token" do
        expect(assigns(:password_reset_token).destroyed?).to eq(true)
      end
    end

    context "without valid data" do
      before do
        put(
          :update,
          id: password_reset_token.id,
          token: password_reset_token.token,
          user: {
            password: "new password",
            confirm_password: "wrong password"
          }
        )
      end

      it { is_expected.to respond_with(:success) }
      it { is_expected.to render_template(:show) }

      it "should assign the user" do
        expect(assigns(:user)).to be_a(User)
      end

      it "should assign the password reset token" do
        expect(assigns(:password_reset_token)).to be_a(PasswordResetToken)
      end

      it "should not destroy the token" do
        expect(assigns(:password_reset_token).destroyed?).to eq(false)
      end
    end

    context "without a valid token" do
      before do
        put :update,
            id: password_reset_token.id,
            user: { password: "new password", confirm_password: "new password" }
      end

      it { is_expected.to redirect_to(login_admin_users_url) }

      it "should set the flash" do
        expect(flash.now[:notice]).to match(/Invalid password reset request/)
      end
    end

    context "with an expired token" do
      before do
        put :update,
            id: expired_password_reset_token.id,
            token: expired_password_reset_token.token,
            user: { password: "new password", confirm_password: "new password" }
      end

      it { is_expected.to redirect_to(login_admin_users_url) }

      it "should assign the password reset token" do
        expect(assigns(:password_reset_token)).to be_a(PasswordResetToken)
      end

      it "should set the flash" do
        expect(flash.now[:notice]).to match(
          /Your password reset link has expired/
        )
      end

      it "should destroy the token" do
        expect(assigns(:password_reset_token).destroyed?).to eq(true)
      end
    end
  end
end
