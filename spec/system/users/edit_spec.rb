# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Editing a user" do
  let(:user) { create(:user) }

  before do
    login_as(user)
    visit edit_admin_user_path(user)
    fill_in "Email address", with: "new@example.com"
    fill_in "Current password", with: current_password
    click_on "Save"
  end

  context "with the current password" do
    let(:current_password) { user.password }

    specify { expect(user.reload.email).to eq("new@example.com") }
  end

  context "with the wrong password" do
    let(:current_password) { "wrong" }

    specify { expect(page).to have_text("Current password is invalid") }
  end
end
