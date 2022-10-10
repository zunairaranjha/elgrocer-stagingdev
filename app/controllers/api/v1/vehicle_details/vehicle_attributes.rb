# frozen_string_literal: true

module API
  module V1
    module VehicleDetails
      class VehicleAttributes < Grape::API
        version 'v1', using: :path
        format :json
        resource :vehicle_details do
          desc "Show Vehicle Attributes"

          params do
            optional :limit, type: Integer, desc: 'Limit of Vehicle Models', documentation: { example: 10 }
            optional :offset, type: Integer, desc: 'Offset of Vehicle Models', documentation: { example: 10 }
          end

          get '/vehicle_attributes' do
            vehicle_models = VehicleModel.all.limit(params[:limit]).offset(params[:offset])
            vehicle_colors = Color.all.limit(params[:limit]).offset(params[:offset])
            present vehicle_models, with: API::V1::VehicleDetails::Entities::ShowVehicleModelEntity
            present vehicle_colors, with: API::V1::VehicleDetails::Entities::ShowColorEntity
          end
        end
      end
    end
  end
end
