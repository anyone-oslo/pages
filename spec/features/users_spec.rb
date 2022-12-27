# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users" do
  let!(:admin) { create(:user, :admin) }
  let!(:user) { create(:user) }

  before do
    login_as(admin)
    click_link "Users"
  end

  describe "removing all roles" do
    before do
      within ".user-#{user.id}" do
        click_link "edit"
      end
      all("input.role").each do |checkbox|
        checkbox.click if checkbox.checked?
      end
      click_button "Save"
      user.reload
    end

    it "removes all roles" do
      expect(user.role_names).to eq([])
    end
  end
end
