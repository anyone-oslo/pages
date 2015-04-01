# encoding: utf-8

require "spec_helper"

describe Category do
  let(:category) { create(:category) }

  it { is_expected.to have_and_belong_to_many(:pages) }

  it { is_expected.to allow_value("Name").for(:name) }
  it { is_expected.not_to allow_value("").for(:name) }
  it { is_expected.not_to allow_value(nil).for(:name) }

  describe "slugging" do
    let(:category) { create(:category, name: "Test category") }
    subject { category.slug }
    it { is_expected.to eq("test-category") }
  end
end
