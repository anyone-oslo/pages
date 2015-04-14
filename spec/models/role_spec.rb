# encoding: utf-8

require "spec_helper"

describe Role do
  let(:role) { create(:role) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:name) }
end
