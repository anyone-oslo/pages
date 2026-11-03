# frozen_string_literal: true

require "rails_helper"

describe Admin::ImagesController do
  let(:user) { create(:user) }
  let(:image) { create(:image) }
  let(:custom_role) { Role::RoleDefinition.new("grants", "Can manage grants", false) }
  let(:upload) do
    Rack::Test::UploadedFile.new(
      File.expand_path("../../support/fixtures/image.png", __dir__),
      "image/png"
    )
  end

  before do
    create(:user, :admin)
    allow(Role).to receive(:roles).and_return([*Role.roles, custom_role])
  end

  describe "GET show" do
    let(:show_image) { get :show, params: { id: image.id }, format: :json }

    context "when the user has no roles" do
      before { login(create(:user, role_names: [])) }

      it "refuses the request" do
        expect { show_image }.to raise_error(PagesCore::NotAuthorized)
      end
    end

    context "when the user has a custom role" do
      before do
        login(create(:user, role_names: %w[grants]))
        show_image
      end

      it { expect(response).to have_http_status(:no_content) }
    end
  end

  describe "POST create" do
    let(:create_image) do
      post :create, params: { image: { file: upload } }, format: :json
    end

    context "when the user has no roles" do
      before { login(create(:user, role_names: [])) }

      it "refuses the request" do
        expect { create_image }.to raise_error(PagesCore::NotAuthorized)
      end
    end

    context "when the user has a custom role" do
      before { login(create(:user, role_names: %w[grants])) }

      it "creates the image" do
        expect { create_image }.to change(Image, :count).by(1)
      end
    end
  end

  describe "PUT update" do
    context "when the user has no roles" do
      before { login(create(:user, role_names: [])) }

      it "refuses the request" do
        expect do
          put :update, params: { id: image.id, image: { decorative: true } },
                       format: :json
        end.to raise_error(PagesCore::NotAuthorized)
      end
    end

    context "when the user has a custom role" do
      before do
        login(create(:user, role_names: %w[grants]))
        put :update, params: { id: image.id, image: { decorative: true } },
                     format: :json
      end

      it "marks the image as decorative" do
        expect(image.reload.decorative).to be(true)
      end
    end

    context "when the user has the pages role" do
      before do
        login(user)
        put :update, params: { id: image.id, image: { decorative: true } },
                     format: :json
      end

      it "marks the image as decorative" do
        expect(image.reload.decorative).to be(true)
      end

      it "renders the decorative flag" do
        expect(response.parsed_body["decorative"]).to be(true)
      end
    end
  end
end
