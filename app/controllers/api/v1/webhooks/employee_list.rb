# frozen_string_literal: true

module API
  module V1
    module Webhooks
      class EmployeeList < Grape::API
        version 'v1', using: :path
        format :json

        resource :webhooks do
          desc 'List of employees'

          params do
            requires :retailer_id, type: Integer, desc: 'Retailer Id', documentation: { example: 16 }
          end

          get '/employee_list' do
            employees = Employee.where(retailer_id: params[:retailer_id])
            present employees, with: API::V1::Webhooks::Entities::EmployeeListEntity
          end
        end
      end
    end
  end
end
