# frozen_string_literal: true

class ImagesController < ApplicationController
  include DynamicImage::Controller

  static_cache :show, :uncropped, :original, permanent: true
  after_action :tag_download

  private

  def tag_download
    return unless action_name == "download" && response.status == 200

    PagesCore::StaticCache.handler.tag_permanently(response, static_cache_tags)
  end

  def static_cache_tags
    [@record.cache_tag]
  end

  def model
    Image
  end
end
