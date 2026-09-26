# frozen_string_literal: true

require "rails_helper"

describe Admin::ImagesController do
  let(:user) { create(:user) }
  let(:image) { create(:image) }

  describe "PUT update" do
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
