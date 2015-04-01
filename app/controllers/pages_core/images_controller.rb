# encoding: utf-8

module PagesCore
  class ImagesController < ApplicationController
    include DynamicImage::Controller

    caches_page :show, :uncropped, :original

    private

    def model
      Image
    end
  end
end
