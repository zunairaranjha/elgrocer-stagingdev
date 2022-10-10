# frozen_string_literal: true

module API
  module V1
    module PickupLocations
      module Entities
        class IndexEntity < API::BaseEntity

          expose :id, documentation: {type: 'Integer', desc: 'Pickup Location id'}, format_with: :integer
          expose :retailer_id , documentation: {type: 'Integer', desc: 'Retailer id'}, format_with: :integer
          expose :details , documentation: {type: 'String', desc: 'Details of Pickup location in English'}, format_with: :string
          expose :longitude , documentation: {type: 'Float', desc: 'Longitude of Pickup ocation'}, format_with: :float
          expose :latitude , documentation: {type: 'Float', desc: 'Latitude of Pickup ocation'}, format_with: :float
          expose :image_url, as: :photo_url , documentation: {type: 'String', desc: 'Url of Photo'}, format_with: :string

          private
          def image_url
            object.photo_url.gsub("/pickup_locs/", "/pickup_locations/")
          end
        end                
      end
    end
  end
end