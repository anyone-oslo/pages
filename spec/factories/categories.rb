# encoding: utf-8

FactoryGirl.define do
  factory :category do
    sequence(:name) { |n| "Category #{n}" }
  end
end
