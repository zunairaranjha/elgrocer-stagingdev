# frozen_string_literal: true

module API
  module V2
    module LocationWithoutShops
      class Update < Grape::API
        version 'v2', using: :path
        format :json
      
        resource :location_without_shops do
          desc "Update user email address in location without stores/shops."
      
          params do
            requires :email, type: String, desc: 'User email for notification'
            requires :location_without_shop_id, type: Integer, desc: 'Location without shops id', documentation: {example: 2}
            optional :store_name, type: String, desc: 'Name of the Store', documentation: {example: 'Ryan Market'}
          end
      
          put do
            location_without_shop = ALocationWithoutShop.find_by(id: params[:location_without_shop_id])
            if location_without_shop
              location_without_shop.update(email: params[:email].to_s.downcase, store_name: params[:store_name])
              true
            end
          end
        end
      end      
    end
  end
end