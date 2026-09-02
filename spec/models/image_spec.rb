# frozen_string_literal: true

require "rails_helper"

RSpec.describe Image do
  describe "#alt_text" do
    subject { image.alt_text }

    context "when the alternative text is set" do
      let(:image) { create(:image, alternative: "A blue square", locale: "en") }

      it { is_expected.to eq("A blue square") }
    end

    context "when the alternative text is blank" do
      let(:image) { create(:image, locale: "en") }

      it { is_expected.to be_nil }
    end

    context "when the locale has no alternative text" do
      let(:image) do
        create(:image, alternative: "A blue square", locale: "en")
          .localize("nb")
      end

      it { is_expected.to be_nil }
    end
  end

  describe "the rendered alt attribute" do
    let(:image) { create(:image, locale: "en") }

    it "is omitted when there is no alternative text" do
      expect(ActionController::Base.helpers.image_tag("/x.png", alt: image.alt_text))
        .not_to include("alt")
    end
  end
end
