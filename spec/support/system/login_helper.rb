# frozen_string_literal: true

module SystemHelpers
  def login_as(user)
    if user.otp_enabled?
      login_with(user.email, user.password,
                 otp: ROTP::TOTP.new(user.otp_secret).now)
    else
      login_with(user.email, user.password)
    end
  end

  def login_with(email, password, otp: nil)
    visit admin_login_path
    fill_in "email", with: email
    fill_in "password", with: password
    click_on "Sign in"
    return unless otp

    fill_in "6 digit code", with: otp
    click_on "Verify"
  end
end
