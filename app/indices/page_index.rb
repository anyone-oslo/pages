ThinkingSphinx::Index.define :page, with: :active_record, delta: ThinkingSphinx::Deltas::DelayedDelta do
  indexes localizations.value,             as: :localization_values
  indexes categories.name,                 as: :category_names
  indexes tags.name,                       as: :tag_names
  indexes [author.realname, author.email], as: :author_name
  indexes [comments.name, comments.body],  as: :comments

  has published_at, created_at, updated_at
  has user_id, parent_page_id
  has status, template
  has autopublish, feed_enabled
  has categories(:id), as: :category_ids
  has tags(:id), as: :tag_ids

  set_property group_concat_max_len: 16.megabytes
end
