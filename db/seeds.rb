puts 'Adding admin user...'
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')

puts 'Adding location...'
locs = FactoryBot.create_list(:location, 10)

puts 'Adding retailer...'
locs.each do |loc|
  FactoryBot.create_list(:retailer, 2, location: loc)
end

puts 'Adding brands...'
brands = FactoryBot.create_list(:brand, 5)

puts 'Adding product to brands...'
brands.each do |brand|
  FactoryBot.create_list(:product, 5, brand: brand)
end

puts 'Adding category...'
categories = FactoryBot.create_list(:category, 5)

puts 'Adding subcategories...'
categories.each do |category|
  FactoryBot.create_list(:category, 2, parent_id: category.id)
end

Category.where.not(parent_id: nil).all.each do |category|
  product = Product.order("RANDOM()").first
  FactoryBot.create(:product_category, category_id: category.id, product_id: product.id)
end

puts 'Adding products to retailers...'
Retailer.all.each do |retailer|
  Product.all.each do |product|
    FactoryBot.create(:shop, retailer: retailer, product: product)
  end
end

puts "Adding settings entry.."
Setting.create(enable_es_search: false)
