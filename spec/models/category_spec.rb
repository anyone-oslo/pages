# encoding: utf-8

require 'spec_helper'

describe Category do
  let(:category) { create(:category) }

  it { should have_and_belong_to_many(:pages) }

  it { should allow_value("Name").for(:name) }
  it { should_not allow_value("").for(:name) }
  it { should_not allow_value(nil).for(:name) }

  describe "slugging" do
    let(:category) { create(:category, name: "Test category") }
    subject { category.slug }
    it { should == "test-category" }
  end
end