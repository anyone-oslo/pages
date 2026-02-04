# frozen_string_literal: true

require "rails_helper"

describe PagesCore::Frontend::PagesController do
  controller(PagesController) do
    template(:home) { |_page| nil }
  end

  let(:user) { create(:user) }

  before do
    routes.draw { post "preview" => "pages#preview" }
    PagesCore.config.localizations = false
  end

  describe "POST preview" do
    subject(:request) { post :preview, params: }

    let(:page) { create(:page, template: "home") }
    let(:preview_page) do
      { name: "Preview title", template: "home" }.to_json
    end
    let(:params) { { page_id: page.id, preview_page: } }

    context "when not authenticated" do
      it "returns 403" do
        request
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when authenticated" do
      before { login(user) }

      it { is_expected.to render_template("pages/templates/home") }

      it "assigns the page with preview attributes" do
        request
        expect(assigns(:page).name).to eq("Preview title")
      end

      it "does not persist changes" do
        request
        expect(page.reload.name).not_to eq("Preview title")
      end
    end

    context "when authenticated with serialized_tags" do
      before { login(user) }

      let(:preview_page) do
        { name: "Tagged preview",
          template: "home",
          serialized_tags: %w[alpha beta].to_json }.to_json
      end

      it "does not raise ReadOnlyRecord" do
        expect { request }.not_to raise_error
      end

      it { is_expected.to render_template("pages/templates/home") }

      it "does not persist tags" do
        request
        expect(page.reload.tags).to be_empty
      end
    end

    context "when authenticated and page_id is not found" do
      before { login(user) }

      let(:params) do
        { page_id: 0,
          preview_page: { name: "New page",
                          template: "home" }.to_json }
      end

      it { is_expected.to render_template("pages/templates/home") }

      it "uses a new page" do
        request
        expect(assigns(:page)).not_to be_persisted
      end
    end
  end
end
