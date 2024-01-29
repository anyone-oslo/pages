# frozen_string_literal: true

module LoginMacros
  def login(user = nil)
    user ||= create(:user)
    session[:current_user] = { id: user.id, token: user.session_token }
  end
end
