# encoding: utf-8

require 'spec_helper'

describe User do
  it { should belong_to(:creator) }
  it { should have_many(:created_users) }
  it { should have_many(:pages) }
  it { should have_many(:password_reset_tokens).dependent(:destroy) }
  it { should have_many(:roles) }
  it { should belong_to(:image) }

  it { should validate_presence_of(:username) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:name) }

  it { should validate_uniqueness_of(:username).case_insensitive }
  it { should validate_uniqueness_of(:email).case_insensitive }

  it { should allow_value("test@example.com").for(:email) }
  it { should allow_value("test+foo@example.com").for(:email) }
  it { should_not allow_value("foo").for(:email) }

  it { should allow_value("long enough").for(:password) }
  it { should_not allow_value("eep").for(:password) }

  describe "password validation" do
    subject { user.valid? }

    context "when passwords match" do
      let(:user) { build(:user, password: 'validpassword', confirm_password: 'validpassword') }
      it { should eq(true) }
    end

    context "when passwords don't match" do
      let(:user) { build(:user, password: 'validpassword', confirm_password: 'invalidpassword') }
      it { should eq(false) }
    end

    context "when confirm_password is omitted" do
      let(:user) { build(:user, password: 'validpassword', confirm_password: nil) }
      it { should eq(false) }
    end
  end
end