# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Invites" do
  let(:user) { create(:user, :admin) }

  describe "Listing invites" do
    before do
      create(:invite, user:, email: "current@example.com")
      create(:invite, user:, email: "expired@example.com", sent_at: 15.days.ago)
      login_as(user)
      visit admin_users_path
    end

    specify do
      expect(page.find("tr", text: "expired@example.com")).to have_text("Expired")
    end

    specify do
      expect(page.find("tr", text: "current@example.com")).to have_no_text("Expired")
    end
  end

  describe "Accepting an invite" do
    let(:invite) { create(:invite, user:, email: "invited@example.com") }

    before { visit admin_invite_with_token_path(invite, invite.token) }

    specify { expect(page).to have_field("Email address", disabled: true) }

    context "when signing up" do
      before do
        fill_in "Name", with: "Invited"
        fill_in "Password", with: "Correct Horse Battery Staple"
        fill_in "Password confirmation", with: "Correct Horse Battery Staple"
        click_on "Sign up"
      end

      specify { expect(User.find_by(email: "invited@example.com")).to be_present }
    end
  end
end
