# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    realname "John Doe"
    email
    password "secret"
  end
end
