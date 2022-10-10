# frozen_string_literal: true

module API
  module V1
    module VehicleDetails
      class Create < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :vehicle_details do
          desc 'Create Vehicle Details!'

          params do
            requires :plate_number, type: String, desc: 'Plate Number of Vehicle', documentation: { example: '1234' }
            requires :vehicle_model_id, type: Integer, desc: 'Model of Vehicle', documentation: { example: 3 }
            requires :vehicle_color_id, type: Integer, desc: 'Color of Vehicle', documentation: { example: 4 }
            requires :company, type: String, desc: 'Company of Vehicle', documentation: { example: 'BMW' }
            optional :collector_id, type: Integer, desc: 'Collector id of Vehicle', documentation: { example: 3 }
            requires :is_deleted, type: Boolean, desc: 'Save This detail or not of Vehicle', documentation: { example: true }
          end

          post '/create' do
            error!(CustomErrors.instance.unauthorized, 421) unless current_shopper
            vehicle = VehicleDetail.new(
              shopper_id: current_shopper.id,
              plate_number: params[:plate_number],
              vehicle_model_id: params[:vehicle_model_id],
              color_id: params[:vehicle_color_id],
              company: params[:company],
              collector_id: params[:collector_id],
              is_deleted: params[:is_deleted],
              date_time_offset: request.headers['Datetimeoffset']
            )
            if vehicle.save!
              present id: vehicle.id
            else
              error!(CustomErrors.instance.unable_to_process_request, 421)
            end
          end
        end
      end
    end
  end
end
