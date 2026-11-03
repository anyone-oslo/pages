# frozen_string_literal: true

require "rails_helper"

describe Admin::AttachmentsController do
  let(:attachment) { create(:attachment) }
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

  describe "POST create" do
    let(:create_attachment) do
      post :create, params: { attachment: { file: upload } }, format: :json
    end

    context "when the user has no roles" do
      before { login(create(:user, role_names: [])) }

      it "refuses the request" do
        expect { create_attachment }.to raise_error(PagesCore::NotAuthorized)
      end
    end

    context "when the user has a custom role" do
      before { login(create(:user, role_names: %w[grants])) }

      it "creates the attachment" do
        expect { create_attachment }.to change(Attachment, :count).by(1)
      end
    end
  end

  describe "PUT update" do
    let(:update_attachment) do
      put :update,
          params: { id: attachment.id,
                    attachment: { name: { en: "Renamed" } } },
          format: :json
    end

    context "when the user has no roles" do
      before { login(create(:user, role_names: [])) }

      it "refuses the request" do
        expect { update_attachment }.to raise_error(PagesCore::NotAuthorized)
      end
    end

    context "when the user has a custom role" do
      before { login(create(:user, role_names: %w[grants])) }

      it "updates the attachment" do
        update_attachment
        expect(attachment.reload.localize(:en).name).to eq("Renamed")
      end
    end
  end
end
