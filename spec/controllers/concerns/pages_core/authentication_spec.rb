# frozen_string_literal: true

require "rails_helper"

describe PagesCore::Authentication do
  controller(ApplicationController) do
    def index
      authenticate!(User.find(params[:id]))
      head :ok
    end
  end

  describe "#authenticate!" do
    before { get :index, params: { id: user.id } }

    context "when user is activated" do
      let(:user) { create(:user) }

      it "responds with success" do
        expect(response).to have_http_status(:ok)
      end
    end

    context "when user is deactivated" do
      let(:user) { create(:user, :deactivated) }

      it { is_expected.to redirect_to(admin_login_url) }

      it "sets the flash" do
        expect(flash[:notice]).to eq(I18n.t("pages_core.invalid_login"))
      end
    end
  end
end
