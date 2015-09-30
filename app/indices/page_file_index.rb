ThinkingSphinx::Index.define :page_file, with: :real_time do
  indexes name
  indexes filename

  has page_id,    type: :integer
  has created_at, type: :timestamp
  has updated_at, type: :timestamp
  has published,  type: :boolean
end
