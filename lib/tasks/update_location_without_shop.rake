require 'airbrake'
require 'airbrake/rack'

namespace :location_without_shop do
    desc "Update all shopper addresses with geolocalization attributes"
    task update_all_location_without_shop: :environment do
        addresses = ALocationWithoutShop.where('street_address IS ? AND street_number IS ? AND route IS ? AND country IS ? AND administrative_area_level_1 IS ? AND locality IS ? AND sublocality IS ? AND neighborhood IS ? AND premise IS ?',nil,nil,nil,nil,nil,nil,nil,nil,nil)
        addresses.each do |address|
            geo_localization = "#{address.latitude},#{address.longitude}"
            address.find_geolocalization(geo_localization)
            sleep(1)
        end
    end
end
