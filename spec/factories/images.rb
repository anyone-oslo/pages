FactoryGirl.define do
  factory :image do
    locale "en"
    file do
      Rack::Test::UploadedFile.new(
        Rails.root.join("..", "support", "fixtures", "image.png"),
        "image/png"
      )
    end
  end
end
