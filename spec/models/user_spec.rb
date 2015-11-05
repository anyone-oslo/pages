# encoding: utf-8

require "rails_helper"

describe User do
  it { is_expected.to belong_to(:creator) }
  it { is_expected.to have_many(:created_users) }
  it { is_expected.to have_many(:pages) }
  it { is_expected.to have_many(:password_reset_tokens).dependent(:destroy) }
  it { is_expected.to have_many(:roles) }
  it { is_expected.to belong_to(:image) }

  it { is_expected.to validate_presence_of(:username) }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:name) }

  it { is_expected.to validate_uniqueness_of(:username).case_insensitive }
  it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

  it { is_expected.to allow_value("test@example.com").for(:email) }
  it { is_expected.to allow_value("test+foo@example.com").for(:email) }
  it { is_expected.not_to allow_value("foo").for(:email) }

  it { is_expected.to allow_value("long enough").for(:password) }
  it { is_expected.not_to allow_value("eep").for(:password) }

  describe "password validation" do
    subject { user.valid? }

    context "when passwords match" do
      let(:user) do
        build(
          :user,
          password: "validpassword",
          confirm_password: "validpassword"
        )
      end
      it { is_expected.to eq(true) }
    end

    context "when passwords don't match" do
      let(:user) do
        build(
          :user,
          password: "validpassword",
          confirm_password: "invalidpassword")
      end
      it { is_expected.to eq(false) }
    end

    context "when confirm_password is omitted" do
      let(:user) do
        build(:user, password: "validpassword", confirm_password: nil)
      end
      it { is_expected.to eq(false) }
    end
  end
end
