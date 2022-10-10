FactoryBot.define do
  factory :recipe do
    name { Faker::Name.name }
    prep_time { 10 }
    cook_time { 10 }
    is_published { true }
    photo { Rack::Test::UploadedFile.new("spec/support/images/square.png", "image/png") }
    chef
  end
end