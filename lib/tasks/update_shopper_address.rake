namespace :shopper_address do
    desc "Update shopper address with geolocalization"
    task update: :environment do
        shopper_addresses = ShopperAddress.order(:id).all

        shopper_addresses.each do |address|
            cord = Geocoder.coordinates(["#{address.street} #{address.building_name} #{address.apartment_number}", 'Dubai', address.area].compact.join(', '))
            cord = [0, 0] unless cord
            address.lonlat = "POINT(#{cord[0]} #{cord[1]})"
            address.save!
            sleep(1)
        end
    end
    desc "Update all shopper addresses with geolocalization attributes"
    task update_all_shoppers_address: :environment do
        shopper_addresses = ShopperAddress.where('street_address IS ? AND street_number IS ? AND route IS ? AND country IS ? AND administrative_area_level_1 IS ? AND locality IS ? AND sublocality IS ? AND neighborhood IS ? AND premise IS ?',nil,nil,nil,nil,nil,nil,nil,nil,nil)
        shopper_addresses.each do |address|
            geo_localization = "#{address.latitude},#{address.longitude}"
            address.find_geolocalization(geo_localization)
            sleep(1)
        end
    end
end
