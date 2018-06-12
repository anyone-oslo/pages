FactoryGirl.define do
  factory :page do
    locale { I18n.default_locale }
    sequence(:name) { |n| "Page #{n}" }
    status 2

    factory :blank_page do
      name nil
    end

    factory :hidden_page do
      status 3
    end

    factory :deleted_page do
      status 4
    end
  end
end
