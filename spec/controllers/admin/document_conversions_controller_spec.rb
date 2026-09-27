# frozen_string_literal: true

require "rails_helper"

describe Admin::DocumentConversionsController do
  let(:user) { create(:user) }

  describe "POST create" do
    context "when logged in" do
      before do
        login(user)
        post :create, params: { text: "h2. Title\n\nSome *bold* text" },
                      format: :json
      end

      it "renders the converted HTML" do
        expect(response.parsed_body["html"]).to include("<strong>bold</strong>")
      end

      it "renders the conversion report" do
        expect(response.parsed_body).to include("raw" => [], "removed" => [])
      end
    end

    context "when not logged in" do
      before do
        user
        post :create, params: { text: "Some text" }, format: :json
      end

      it { is_expected.to redirect_to(admin_login_url) }
    end
  end
end
