module PagesCore::LoginHelper
  def login_form(success_url:, login_url:)
    render partial: "admin/users/login_form", locals: { success_url: success_url, login_url: login_url }
  end

  def logout_link(name, login_url:)
    link_to name, session_path(login_url: login_url), method: 'delete'
  end
end
