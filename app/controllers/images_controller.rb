# frozen_string_literal: true

class ImagesController < ApplicationController
  include DynamicImage::Controller

  static_cache :show, :uncropped, :original, permanent: true

  private

  def model
    Image
  end
end
