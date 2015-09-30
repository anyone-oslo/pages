# encoding: utf-8

ThinkingSphinx::Index.define :page, with: :real_time do
  indexes localization_values
  indexes category_names
  indexes tag_list
  indexes author.name,  as: :author_name
  indexes author.email, as: :author_email
  indexes comment_names
  indexes comment_bodies
  indexes file_names
  indexes file_filenames

  has category_ids,   type: :integer, multi: true
  has tag_ids,        type: :integer, multi: true

  has published_at,   type: :timestamp
  has created_at,     type: :timestamp
  has updated_at,     type: :timestamp
  has user_id,        type: :integer
  has parent_page_id, type: :integer
  has status,         type: :integer
  has template,       type: :string
  has autopublish,    type: :boolean
  has feed_enabled,   type: :boolean
  has published,      type: :boolean

  set_property group_concat_max_len: 16.megabytes
end
