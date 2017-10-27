FactoryGirl.define do
  factory :page_path do
    locale "en"
    sequence(:path) { |n| "path-#{n}" }
    page
  end
end
