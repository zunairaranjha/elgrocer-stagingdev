# frozen_string_literal: true

module API
  module V1
    module CollectorDetails
      class Create < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :collector_details do
          desc 'Create Collector details'

          params do
            requires :name, type: String, desc: 'Name of Collector'
            requires :phone_number, type: String, desc: 'Phone number of collector'
            requires :is_deleted, type: Boolean, desc: 'Save collector details or not'
          end

          post '/create' do
            error!(CustomErrors.instance.unauthorized, 421) unless current_shopper
            collector = CollectorDetail.new(
              shopper_id: current_shopper.id,
              name: params[:name],
              phone_number: params[:phone_number],
              is_deleted: params[:is_deleted],
              date_time_offset: request.headers['Datetimeoffset']
            )
            if collector.save!
              present id: collector.id
            else
              error!(CustomErrors.instance.unable_to_process_request, 421)
            end
          end
        end
      end
    end
  end
end
