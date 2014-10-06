# encoding: utf-8

ThinkingSphinx::Index.define :user, with: :real_time do
  indexes username
  indexes name
  indexes email

  has last_login_at, type: :timestamp
  has created_at, type: :timestamp
  has activated, type: :boolean
end
