# frozen_string_literal: true

require "rails_helper"

describe ErrorsController do
  describe "GET show" do
    context "with a known status code" do
      before { get :show, params: { id: 404 } }

      it { is_expected.to render_template("errors/404") }

      it "responds with the matching status" do
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with an unknown status code" do
      before { get :show, params: { id: 999 } }

      it { is_expected.to render_template("errors/404") }

      it "responds with 404" do
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with a non-numeric id" do
      before { get :show, params: { id: ".env" } }

      it { is_expected.to render_template("errors/404") }

      it "responds with 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
