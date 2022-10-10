FactoryBot.define do
  factory :brand do
    name { ('a'..'g').to_a.shuffle.join }
  end
  factory :product do
    name { "Oat bran" }
    barcode { ('0'..'9').to_a.shuffle.join }
    shelf_life { 10 }
    size_unit { "150 ml" }
    country_alpha2 { "PL" }
    is_local { true }
    photo { Rack::Test::UploadedFile.new("spec/support/images/square.png", "image/png") }
    brand 
  end
end