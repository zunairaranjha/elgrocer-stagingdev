module API
  module V1
    module VehicleDetails
      class Index < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :vehicle_details do
          desc "Show Vehicle Details"
          params do
            requires :limit, type: Integer, desc: 'Limit of orders', documentation: { example: 20 }
            requires :offset, type: Integer, desc: 'Offset of orders', documentation: { example: 10 }
          end

          get '/all' do
            error!(CustomErrors.instance.unauthorized, 421) unless current_shopper
            result = VehicleDetail.includes(:color, :vehicle_model).where(shopper_id: current_shopper.id, is_deleted: false).limit(params[:limit]).offset(params[:offset])
            present result, with: API::V1::VehicleDetails::Entities::ShowEntity
          end
        end
      end
    end
  end
end