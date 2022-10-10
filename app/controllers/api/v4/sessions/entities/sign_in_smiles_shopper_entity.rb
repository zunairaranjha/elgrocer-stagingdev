# frozen_string_literal: true

module API
  module V4
    module Sessions
      module Entities
        class SignInSmilesShopperEntity < API::V1::Sessions::Entities::SignInShopperEntity
          unexpose [
                     :invoice_city,
                     :invoice_street,
                     :invoice_building_name,
                     :invoice_apartment_number,
                     :invoice_floor_number,
                     :invoice_location_id,
                     :invoice_location_name
                   ]
        end
      end
    end
  end
end