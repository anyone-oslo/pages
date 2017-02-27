# encoding: utf-8

class PagesCore::ImagesController < ::ApplicationController
  include DynamicImage::Controller

  caches_page :show, :uncropped, :original

  private

  def model
    Image
  end
end
