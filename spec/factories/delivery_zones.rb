FactoryBot.define do
  factory :delivery_zone do
    sequence(:name) { |n| "delivery_zone#{n}" }
    coordinates { 'POLYGON((55.2726 25.2388,55.2772 25.2450,55.2823 25.2422,55.2851 25.2463,55.2954 25.2396,55.3047 25.2349,55.2987 25.2259,55.2946 25.2275,55.2926 25.2253,55.2842 25.2289,55.2787 25.2348,55.2728 25.2384,55.2723 25.2390,55.2726 25.2388))' }
  end
end