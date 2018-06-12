FactoryGirl.define do
  factory :page_file do
    locale "en"
    page
    file do
      Rack::Test::UploadedFile.new(
        Rails.root.join("..", "support", "fixtures", "image.png"),
        "image/png"
      )
    end
  end
end
