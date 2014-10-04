# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    realname "John Doe"
    email
    password "Correct Horse Battery Staple"
    confirm_password "Correct Horse Battery Staple"
  end
end
