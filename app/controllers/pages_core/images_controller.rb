# encoding: utf-8

class PagesCore::ImagesController < ApplicationController
  include DynamicImage::Controller

  private

  def model
    Image
  end
end
