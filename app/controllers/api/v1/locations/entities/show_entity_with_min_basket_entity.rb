# frozen_string_literal: true

module API
  module V1
    module Locations
      module Entities
        class ShowEntityWithMinBasketEntity < API::V1::Locations::Entities::ShowEntity
          def self.entity_name
            'show_location_with_min_basket'
          end
        
          expose :min_basket_value, documentation: { type: 'Integer', desc: "Describes if there is at least one shop in the location", format_with: :integer } do |item, options|
            item.min_basket_value(options[:retailer_id])
          end
        
          def min_basket_value(retailer_id)
            object.min_basket_value(retailer_id)
          end
        end        
      end
    end
  end
end