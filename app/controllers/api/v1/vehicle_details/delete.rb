module API
  module V1
    module VehicleDetails
      class Delete < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :vehicle_details do
          desc "Delete Vehicle Details"
          params do
            requires :id, type: Integer, desc: 'id of Vehicle', documentation: { example: 3 }
          end

          put '/delete' do
            error!(CustomErrors.instance.unauthorized, 421) unless current_shopper
            VehicleDetail.where(id: params[:id], shopper_id: current_shopper.id).update_all(is_deleted: true, updated_at: Time.now)
            present message: true
          end
        end
      end
    end
  end
end
