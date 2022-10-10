# frozen_string_literal: true

module API
  module V1
    module ShopperAddresses
      class Delete < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :shopper_addresses do
          desc "Allows deleting of an adress of a shopper. Requires authentication"
          params do
            requires :address_id, type: Integer, desc: "Id of an address"
          end
      
          delete do
            shopper_id = current_shopper.id
            error!(CustomErrors.instance.order_with_address_processed, 421) if Order.where(shopper_id: shopper_id, shopper_address_id: params[:address_id]).where.not(status_id: [2,3,4,5]).exists?
            full_params = params.merge(shopper_id: shopper_id)
            result = ::ShopperAddresses::Delete.run(full_params)
            if result.valid?
              # result.result
              # status 204
              {message: 'ok'}
            else
              error!(result.errors, 422)
            end
      
          end
      
        end
      end
    end
  end
end