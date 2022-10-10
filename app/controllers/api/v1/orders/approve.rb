module API
    module V1
        module Orders
            class Approve < Grape::API
                include TokenAuthenticable
                version 'v1', using: :path
                format :json
            
                resource :orders do
                    desc "Allows approving an order", entity: API::V1::Orders::Entities::ShowEntity
                    params do
                        requires :order_id, type: Integer, desc: "ID of the order", documentation: { example: 16 }
                    end
            
                    put '/approve' do
                        target_user = current_retailer || current_shopper
                        if target_user.class.name.downcase.eql?("retailer")
                            error!({error_code: 401, error_message: "Only shoppers can approve orders!"},401)
                        else
                            f_parameters = params.merge({shopper_id: target_user.id})
                            result = ::Orders::Approve.run(f_parameters)
                            if result.valid?
                                #present result.result, with: API::V1::Orders::Entities::ShowEntity
                                true
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