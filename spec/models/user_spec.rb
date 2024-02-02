# frozen_string_literal: true

require "rails_helper"

describe User do
  subject(:user) { build(:user) }

  it { is_expected.to belong_to(:creator).optional }
  it { is_expected.to have_many(:created_users) }
  it { is_expected.to have_many(:pages) }
  it { is_expected.to have_many(:roles) }
  it { is_expected.to belong_to(:image).optional }

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:name) }

  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

  it { is_expected.to allow_value("test@example.com").for(:email) }
  it { is_expected.to allow_value("test+foo@example.com").for(:email) }
  it { is_expected.not_to allow_value("foo").for(:email) }

  it { is_expected.to allow_value("long enough").for(:password) }
  it { is_expected.not_to allow_value("eep").for(:password) }

  describe "email normalization" do
    subject(:user) { build(:user, email: "  whitespace@example.com ") }

    it { is_expected.to be_valid }
    specify { expect(user.email).to eq("whitespace@example.com") }
  end

  describe ".find_by(email)" do
    subject { described_class.find_by(email:) }

    let!(:user) { create(:user, email: "test@example.com") }
    let(:email) { "test@example.com" }

    it { is_expected.to eq(user) }

    context "when query includes whitespace" do
      let(:email) { " test@example.com  " }

      it { is_expected.to eq(user) }
    end

    context "when query is the wrong case" do
      let(:email) { "Test@EXAMPLE.COM" }

      it { is_expected.to eq(user) }
    end
  end

  describe "password validation" do
    subject { user.valid? }

    context "when passwords match" do
      let(:user) do
        build(
          :user,
          password: "validpassword",
          password_confirmation: "validpassword"
        )
      end

      it { is_expected.to be(true) }
    end

    context "when passwords don't match" do
      let(:user) do
        build(
          :user,
          password: "validpassword",
          password_confirmation: "invalidpassword"
        )
      end

      it { is_expected.to be(false) }
    end
  end

  describe "session_token" do
    subject(:session_token) { user.session_token }

    let(:user) { create(:user, :otp) }

    it { is_expected.to be_present }

    it "changes when password is changed" do
      previous = user.session_token
      user.update(password: "new password")
      expect(session_token).not_to eq(previous)
    end

    it "changes when OTP status is changed" do
      previous = user.session_token
      user.update(otp_enabled: false)
      expect(session_token).not_to eq(previous)
    end
  end
end
