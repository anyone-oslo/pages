FactoryGirl.define do
  factory :localization do
    name { "name" }
    locale { "nb" }
    association :localizable, :factory => :page
  end
end
