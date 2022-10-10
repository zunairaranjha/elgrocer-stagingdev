# frozen_string_literal: true

module API
  module V1
    module Webhooks
      class EmployeeDetail < Grape::API
        version 'v1', using: :path
        format :json

        resource :webhooks do
          desc 'To get the Employee Detail'

          params do
            requires :employee_id, type: Integer, desc: 'Id of the Employee', documentation: { example: 5 }
            optional :retailer_id, type: Integer, desc: 'Retailer Id', documentation: { example: 16 }
            optional :order_id, type: Integer, desc: 'Order Id ', documentation: { example: 23456784567 }
          end

          get '/employee_detail' do
            employee = Employee.find_by(id: params[:employee_id])
            error!(CustomErrors.instance.employee_not_exist, 421) unless employee
            present employee, with: API::V1::Webhooks::Entities::EmployeeDetail, retailer_id: params[:retailer_id], order_id: params[:order_id]
          end
        end
      end
    end
  end
end
