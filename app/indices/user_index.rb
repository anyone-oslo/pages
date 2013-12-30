# encoding: utf-8

ThinkingSphinx::Index.define :user, with: :active_record, delta: ThinkingSphinx::Deltas::DelayedDelta do
  indexes username
  indexes realname
  indexes email
  indexes mobile

  has last_login_at
  has created_at
  has is_activated
end
