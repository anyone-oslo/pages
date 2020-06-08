# frozen_string_literal: true

module LoginMacros
  def login(user = nil)
    @current_user = user || create(:user)
    session[:current_user_id] = @current_user.id
  end
end
