# frozen_string_literal: true

require "rails_helper"

RSpec.describe PagesCore::CreateUserService do
  let(:attributes) { attributes_for(:user) }

  describe "with invite" do
    subject(:user) { described_class.call(attributes, invite: invite) }

    let(:invite) { create(:invite, role_names: ["users"]) }

    context "when attributes are valid" do
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
        user
        expect(invite.destroyed?).to eq(true)
      end

      it "publishes an event" do
        result = nil
        PagesCore::PubSub.subscribe(:create_user) { |p| result = p }
        user
        expect([result[:user], result[:invite]]).to eq([user, invite])
      end
    end

    context "when attributes are invalid" do
      let(:attributes) { attributes_for(:user).merge(email: "foo") }

      it { is_expected.to be_a(User) }
      it { is_expected.not_to be_valid }

      it "does not destroy the invite" do
        expect(invite.destroyed?).to eq(false)
      end

      it "does not publish an event" do
        result = nil
        PagesCore::PubSub.subscribe(:create_user) { |p| result = p }
        user
        expect(result).to eq(nil)
      end
    end
  end

  describe "without invite" do
    subject(:user) { described_class.call(attributes) }

    it "returns a valid user" do
      expect(user).to be_valid
    end
  end
end
