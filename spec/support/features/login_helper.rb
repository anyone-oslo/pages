# frozen_string_literal: true

module Features
  def login_as_admin
    login_as(create(:user, :admin))
  end

  def login_as(user = nil)
    user ||= create(:user)
    login_with(user.email, user.password)
  end

  def login_with(email, password)
    visit login_admin_users_path
    within ".password.login-tab" do
      fill_in "email", with: email
      fill_in "password", with: password
      click_button "Sign in"
    end
  end

  def user_is_logged_in
    expect(page).to(have_text("Log out"))
  end

  def user_is_logged_out
    expect(page).to(
      have_text("Please enter your email address and password to sign in")
    )
  end
end
