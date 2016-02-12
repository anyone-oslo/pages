# encoding: utf-8

require "rails_helper"

describe Role, type: :model do
  let(:role) { create(:role) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:name) }
end
