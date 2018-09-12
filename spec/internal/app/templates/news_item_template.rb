class NewsItemTemplate < ApplicationTemplate
  enabled_blocks :headline, :name, :excerpt, :body, :video_embed

  render do |page|
    @home_page = page
  end
end
