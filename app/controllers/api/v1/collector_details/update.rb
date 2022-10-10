# frozen_string_literal: true

module API
  module V1
    module CollectorDetails
      class Update < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :collector_details do
          desc 'Update Collector details'

          params do
            requires :id, type: Integer, desc: 'id of collector'
            optional :name, type: String, desc: 'Name of Collector'
            optional :phone_number, type: String, desc: 'Phone number of collector'
          end

          put '/update' do
            error!(CustomErrors.instance.only_shopper_can_change, 421) unless current_shopper
            collector = CollectorDetail.find_by(id: params[:id], shopper_id: current_shopper.id)
            error!(CustomErrors.instance.collector_not_found, 421) unless collector
            object = {
              name: params[:name],
              phone_number: params[:phone_number],
              date_time_offset: request.headers['Datetimeoffset']
            }
            present message: collector.update!(object.compact)
          end
        end
      end
    end
  end
end
