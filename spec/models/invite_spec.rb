require "rails_helper"

describe Invite, type: :model do
  subject { build(:invite) }

  it { is_expected.to belong_to(:user) }
  it do
    is_expected.to have_many(:roles)
      .dependent(:destroy)
      .class_name("InviteRole")
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

    it { is_expected.to allow_value("test@example.com").for(:email) }
    it { is_expected.to allow_value("test+foo@example.com").for(:email) }
    it { is_expected.not_to allow_value("foo").for(:email) }
  end

  describe "#create_user" do
    let!(:invite) { create(:invite, role_names: ["users"]) }
    let!(:user) { invite.create_user(attributes) }
    subject { user }

    context "when attributes are valid" do
      let(:attributes) { attributes_for(:user) }

      it { is_expected.to be_a(User) }
      it { is_expected.to be_valid }

      it "should set the creator" do
        expect(user.creator).to eq(invite.user)
      end

      it "should inherit the roles" do
        expect(subject.role_names).to eq(["users"])
      end

      it "should be activated" do
        expect(subject.activated?).to eq(true)
      end

      it "should destroy the invite" do
        expect(invite.destroyed?).to eq(true)
      end
    end

    context "when attributes are invalid" do
      let(:attributes) { attributes_for(:user).merge(email: "foo") }

      it { is_expected.to be_a(User) }
      it { is_expected.not_to be_valid }

      it "should not destroy the invite" do
        expect(invite.destroyed?).to eq(false)
      end
    end
  end

  describe "#token" do
    let(:invite) { create(:invite) }
    subject { invite.token }

    it "should generate a token" do
      expect(subject.length).to eq(64)
    end
  end
end
