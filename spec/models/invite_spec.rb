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
    subject!(:user) { invite.create_user(attributes) }

    let(:invite) { create(:invite, role_names: ["users"]) }

    context "when attributes are valid" do
      let(:attributes) { attributes_for(:user) }

      it { is_expected.to be_a(User) }
      it { is_expected.to be_valid }

      it "sets the creator" do
        expect(user.creator).to eq(invite.user)
      end

      it "inherits the roles" do
        expect(user.role_names).to eq(["users"])
      end

      it "is activated" do
        expect(user.activated?).to eq(true)
      end

      it "destroys the invite" do
        expect(invite.destroyed?).to eq(true)
      end
    end

    context "when attributes are invalid" do
      let(:attributes) { attributes_for(:user).merge(email: "foo") }

      it { is_expected.to be_a(User) }
      it { is_expected.not_to be_valid }

      it "does not destroy the invite" do
        expect(invite.destroyed?).to eq(false)
      end
    end
  end

  describe "#token" do
    subject(:token) { invite.token }

    let(:invite) { create(:invite) }

    it "generates a token" do
      expect(token.length).to eq(64)
    end
  end
end
