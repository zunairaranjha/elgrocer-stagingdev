module API
    module V1
        module Orders
            class DeleteShopper < Grape::API
                include TokenAuthenticable
                version 'v1', using: :path
                format :json
            
                resource :orders do
                    desc "Allows marking an order as deleted for shopper", entity: API::V1::Orders::Entities::ShowEntity
                    params do
                        requires :order_id, type: Integer, desc: 'Order ID'
                    end
            
                    delete '/shopper' do
                        result = ::Orders::DeleteShopper.run(params.merge({shopper_id: current_shopper.id}))
                        if result.valid?
                            result.result
                        else
                            error!({error_code: 422, error_message: result.errors},422)
                        end
                    end
                end
            end            
        end
    end
end