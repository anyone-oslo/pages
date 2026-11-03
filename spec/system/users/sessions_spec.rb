# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Logging out all sessions" do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }

  before do
    Capybara.using_session(:other) { login_as(user) }
    login_as(current)
    visit edit_admin_user_path(user)
    click_on "Log out all sessions"
  end

  context "when logging out your own sessions" do
    let(:current) { user }

    specify { expect(page).to have_text("Sessions have been logged out") }
    specify { expect(page).to have_current_path(edit_admin_user_path(user)) }

    it "logs out the other session" do
      Capybara.using_session(:other) do
        visit admin_users_path
        expect(page).to have_button("Sign in")
      end
    end
  end

  context "when an admin logs out another user" do
    let(:current) { admin }

    specify { expect(page).to have_current_path(edit_admin_user_path(user)) }

    it "logs out the user" do
      Capybara.using_session(:other) do
        visit admin_users_path
        expect(page).to have_button("Sign in")
      end
    end
  end
end
