namespace :locations do
  desc 'It creates the first city and assigns it to the existing locations (without city_id)'
  task set_city: :environment do
    city = City.create(name: 'Dubai')
    Location.where(city_id: nil).each do |location|
      location.update_attributes(city: city)
    end
  end
end
