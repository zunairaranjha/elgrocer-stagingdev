module API
  module V1
    module ShopperAddresses
      class Index < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :shopper_addresses do
          desc "List of all addresses of current shopper. Requires authentication", entity: API::V1::ShopperAddresses::Entities::IndexEntity
      
          get do
            if current_shopper.blank?
              error!({error_code: 401, error_message: "You are not logged in!"},401)
            else
              addresses = current_shopper.shopper_addresses.includes(:address_tag)
              result = {addresses: addresses}
              present result, with: API::V1::ShopperAddresses::Entities::IndexEntity
            end
          end
        end
      end      
    end
  end
end