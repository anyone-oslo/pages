require "rails_helper"

describe ErrorsController, type: :feature do
  around :each do |example|
    Rails.application.config.consider_all_requests_local = false
    Rails.application.config.action_dispatch.show_exceptions = true
    example.run
    Rails.application.config.consider_all_requests_local = true
    Rails.application.config.action_dispatch.show_exceptions = false
  end

  xit "should render 500" do
    visit "/errors/exception"
    expect(page).to have_content("Something went terribly wrong")
  end

  xit "should render 404" do
    visit "/errors/not_found"
    expect(page).to have_content("Page not found")
  end

  xit "should render 403" do
    visit "/errors/not_authorized"
    expect(page).to(
      have_content("You are not authorized to access this resource")
    )
  end
end
