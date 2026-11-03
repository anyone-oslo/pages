# frozen_string_literal: true

require "rails_helper"

describe Admin::AccountRecoveriesController do
  let(:user) { create(:user, :deactivated) }
  let(:token) { user.password_reset_token }

  describe "PUT update" do
    context "when user is deactivated" do
      before do
        put :update, params: {
          token:,
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
