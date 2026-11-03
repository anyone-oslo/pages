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
    it { is_expected.not_to allow_value("test@example").for(:email) }
  end

  describe "#token" do
    subject(:token) { invite.token }

    let(:invite) { create(:invite) }

    it "generates a token" do
      expect(token.length).to eq(64)
    end
  end

  describe "#expired?" do
    subject { invite.expired? }

    it { is_expected.to be(false) }

    context "when sent more than 14 days ago" do
      let(:invite) { build(:invite, sent_at: 15.days.ago) }

      it { is_expected.to be(true) }
    end

    context "when never sent" do
      let(:invite) { build(:invite, sent_at: nil) }

      it { is_expected.to be(true) }
    end
  end

  describe "#acceptable?" do
    subject { invite.acceptable? }

    let(:inviter) { create(:user, :admin) }
    let(:invite) { build(:invite, user: inviter) }

    before { create(:user) }

    it { is_expected.to be(true) }

    context "when expired" do
      let(:invite) { build(:invite, user: inviter, sent_at: 15.days.ago) }

      it { is_expected.to be(false) }
    end

    context "when the inviter is deactivated" do
      let(:inviter) { create(:user, :admin, activated: false) }

      it { is_expected.to be(false) }
    end

    context "when the inviter no longer has the users role" do
      let(:inviter) { create(:user, role_names: %w[pages]) }

      it { is_expected.to be(false) }
    end
  end
end
