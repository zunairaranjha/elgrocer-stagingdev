# frozen_string_literal: true

module API
  module V1
    module Orders
      class ChangePaymentType < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :orders do
          desc "Change Payment Type for Order", entity: API::V1::Orders::Entities::ShowEntity
          params do
            requires :order_id, type: Integer, desc: "ID of the order", documentation: { example: 16 }
            requires :payment_type_id, type: Integer, desc: "Payment Type ID for order", documentation: { example: 16 }
          end
      
          put '/change_payment_type' do
            if current_retailer
              error!({error_code: 401, error_message: "Only shoppers can change!"},401)
            else
              f_parameters = params.merge({shopper_id: current_shopper.id})
              result = ::Orders::ChangePaymentType.run(f_parameters)
              if result.valid?
                present result.result, with: API::V1::Orders::Entities::ShowEntity
              else
                error!({error_code: 422, error_message: result.errors},422)
              end
            end
          end
        end
      end      
    end
  end
end
