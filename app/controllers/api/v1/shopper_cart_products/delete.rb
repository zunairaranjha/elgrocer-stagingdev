# frozen_string_literal: true

module API
  module V1
    module ShopperCartProducts
      class Delete < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :shopper_cart_products do
          desc 'Allows deleting of a product from a cart for a shopper. Requires authentication'
          params do
            requires :retailer_id, type: Integer, desc: 'Retailer Id'
          end

          delete do
            if current_retailer
              error!({ error_code: 401, error_message: 'Only shoppers can!' }, 401)
            else
              full_params = params.merge(shopper_id: current_shopper.id)
              result = ::ShopperCartProducts::Delete.run(full_params)
              if result.valid?
                result.result
              else
                error!(result.errors, 422)
              end
            end
          end
        end
      end
    end
  end
end
