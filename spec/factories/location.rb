FactoryBot.define do

  factory :location do
    sequence(:name) { |n| "location#{n}" }
    city
  end
end
