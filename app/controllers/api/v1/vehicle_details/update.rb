module API
  module V1
    module VehicleDetails
      class Update < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :vehicle_details do
          desc 'Update vehicle details'
          params do
            requires :id, type: Integer, desc: 'Id of Vehicle_detail', documentation: { example: 3 }
            optional :plate_number, type: String, desc: 'Update Vehicle Plate number', documentation: { example: '1234' }
            optional :vehicle_model_id, type: Integer, desc: 'Update Vehicle model Id', documentation: { example: 1 }
            optional :vehicle_color_id, type: Integer, desc: 'Update Vehicle model id', documentation: { example: 3 }
            optional :company, type: String, desc: 'Update Vehicle Company Name', documentation: { example: '1234' }
            optional :collector_id, type: Integer, desc: 'Update Vehicle Collector Id', documentation: { example: 3 }
          end

          put '/update' do
            error!(CustomErrors.instance.only_shopper_can_change, 421) unless current_shopper
            vehicle = VehicleDetail.find_by(id: params[:id], shopper_id: current_shopper.id)
            error!(CustomErrors.instance.vehicle_not_found, 421) unless vehicle
            object = {
              plate_number: params[:plate_number],
              vehicle_model_id: params[:vehicle_model_id],
              color_id: params[:vehicle_color_id],
              company: params[:company],
              collector_id: params[:collector_id],
              date_time_offset: request.headers['Datetimeoffset']
            }
            present message: vehicle.update!(object.compact)
          end
        end
      end
    end
  end
end
