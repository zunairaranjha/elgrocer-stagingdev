# frozen_string_literal: true

module API
  module V1
    module Favourites
      module Entities
        class IndexRetailersEntity < API::BaseEntity
          expose :retailers, using: API::V1::Favourites::Entities::ShowRetailer, documentation: {type: 'show_retailer', is_array: true }
        end                
      end
    end
  end
end