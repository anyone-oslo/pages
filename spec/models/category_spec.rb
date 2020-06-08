# frozen_string_literal: true

require "rails_helper"

describe Category, type: :model do
  let(:category) { create(:category) }

  it { is_expected.to have_many(:page_categories).dependent(:destroy) }
  it { is_expected.to have_many(:pages).through(:page_categories) }

  it { is_expected.to allow_value("Name").for(:name) }
  it { is_expected.not_to allow_value("").for(:name) }
  it { is_expected.not_to allow_value(nil).for(:name) }

  describe "slugging" do
    subject { category.slug }

    let(:category) { create(:category, name: "Test category") }

    it { is_expected.to eq("test-category") }
  end
end
