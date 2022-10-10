module API
  module V1
    module Orders
      class Available < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :orders do
          desc "Update was_in_shop", entity: API::V1::Orders::Entities::ShowEntity
          params do
            requires :order_id, type: Integer, desc: "ID of the retailer", documentation: { example: 16 }
            requires :positions, type: Array do
              requires :was_in_shop, type: Boolean, desc: "Describes if the product is in shop's stock", documentation: { example: false}
              requires :position_id, type: Integer, desc: "Desired amount of product", documentation: { example: "5"}
            end
          end
      
          put '/available' do
            if current_shopper
              error!({error_code: 401, error_message: "Only retailers can update was_in_shop!"},401)
            else
              f_parameters = params.merge(retailer_id: current_retailer.id)
              result = ::Orders::UpdateAvailablePositions.run(f_parameters)
              if result.valid?
                present result.result, with: API::V1::Orders::Entities::ShowEntity, retailer: current_retailer
              else
                r_err = result.errors
                sts_err = r_err['status_id']
      
                if sts_err
                  error!({error_code: 453, error_message: result.errors},453)
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
end