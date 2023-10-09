# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Error handling", :realistic_error_responses) do
  it "renders a 404 page" do
    visit "/errors/not_found"
    expect(page).to have_content("Page not found")
  end

  it "renders a 403 page" do
    visit "/errors/not_authorized"
    expect(page).to(
      have_content("You are not authorized to access this resource")
    )
  end
end
