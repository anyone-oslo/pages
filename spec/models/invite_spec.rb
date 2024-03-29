# frozen_string_literal: true

require "rails_helper"

describe Invite do
  subject(:invite) { build(:invite) }

  it { is_expected.to belong_to(:user) }

  it do
    expect(invite).to have_many(:roles)
      .dependent(:destroy)
      .class_name("InviteRole")
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

    it { is_expected.to allow_value("test@example.com").for(:email) }
    it { is_expected.to allow_value("test+foo@example.com").for(:email) }
    it { is_expected.not_to allow_value("foo").for(:email) }
  end

  describe "#token" do
    subject(:token) { invite.token }

    let(:invite) { create(:invite) }

    it "generates a token" do
      expect(token.length).to eq(64)
    end
  end
end
