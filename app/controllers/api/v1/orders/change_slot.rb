module API
    module V1
      module Orders
          class ChangeSlot < Grape::API
              include TokenAuthenticable
              version 'v1', using: :path
              format :json
          
              resource :orders do
                  desc "Change schedule order to instant", entity: API::V1::Orders::Entities::ShowEntity
                    params do
                      requires :order_id, type: Integer, desc: "ID of the order", documentation: { example: 16 }
                      optional :delivery_slot_id, type: Integer, desc: "new delivery slot id for order", documentation: { example: 16 }
                      optional :week, type: Integer, desc: "Week of the year for which order is being placed", documentation: { example: 14 }
                    end
          
                    put '/change_slot' do
                        if current_retailer
                          error!({error_code: 401, error_message: "Only shoppers can change schedule order to instant order!"},401)
                        else
                          params[:week] = params[:week].to_i - 60 if params[:week].to_i > 59
                          f_parameters = params.merge({shopper_id: current_shopper.id})
                          result = ::Orders::ChangeSlot.run(f_parameters)
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