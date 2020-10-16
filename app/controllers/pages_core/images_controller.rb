# frozen_string_literal: true

module PagesCore
  class ImagesController < ::ApplicationController
    include DynamicImage::Controller

    static_cache :show, :uncropped, :original, permanent: true

    private

    def model
      Image
    end
  end
end
