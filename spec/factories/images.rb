# encoding: utf-8

FactoryGirl.define do
  factory :image do
    locale "en"
    file Rack::Test::UploadedFile.new(
      Rails.root.join("../support/fixtures/image.png"),
      "image/png"
    )
  end
end
