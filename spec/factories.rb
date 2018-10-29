# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category #{n}" }
  end

  factory :image do
    locale { "en" }
    file do
      Rack::Test::UploadedFile.new(
        Rails.root.join("..", "support", "fixtures", "image.png"),
        "image/png"
      )
    end
  end

  factory :invite do
    email
    user
  end

  factory :localization do
    name { "name" }
    locale { "nb" }
    association :localizable, factory: :blank_page
  end

  factory :page_file do
    locale { "en" }
    page
    file do
      Rack::Test::UploadedFile.new(
        Rails.root.join("..", "support", "fixtures", "image.png"),
        "image/png"
      )
    end
  end

  factory :page_path do
    locale { "en" }
    sequence(:path) { |n| "path-#{n}" }
    page
  end

  factory :page do
    locale { I18n.default_locale }
    sequence(:name) { |n| "Page #{n}" }
    status { 2 }

    factory :blank_page do
      name { nil }
    end

    factory :hidden_page do
      status { 3 }
    end

    factory :deleted_page do
      status { 4 }
    end
  end

  factory :password_reset_token do
    user
  end

  factory :role do
    user
    name { "pages" }
  end

  factory :tag do
    sequence(:name) { |n| "Tag #{n}" }
  end

  factory :user do
    sequence(:name) { |n| "John Doe #{n}" }
    email
    password { "Correct Horse Battery Staple" }
    confirm_password { "Correct Horse Battery Staple" }
    activated { true }
    role_names { %w[pages] }

    trait :admin do
      role_names { %w[pages users] }
    end
  end

  sequence :email do |n|
    "person#{n}@example.com"
  end

  sequence :sha1hash do |n|
    Digest::SHA1.hexdigest(n.to_s)
  end
end
