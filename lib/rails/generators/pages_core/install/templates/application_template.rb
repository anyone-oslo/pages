# encoding: utf-8

class ApplicationTemplate < PagesCore::Template
  comments false
  comments_allowed true
  files false
  images false
  tags false

  enabled_blocks :headline, :excerpt, :body
end
