# encoding: utf-8

ThinkingSphinx::Index.define :user, with: :real_time do
  indexes username
  indexes realname
  indexes email
  indexes mobile

  has last_login_at, type: :timestamp
  has created_at, type: :timestamp
  has is_activated, type: :boolean
end
