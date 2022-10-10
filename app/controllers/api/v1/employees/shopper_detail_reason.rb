# frozen_string_literal: true

module API
  module V1
    module Employees
      class ShopperDetailReason < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :employees do
          desc 'Get and Store reason to view the shopper detail'

          params do
            requires :reason, type: String, desc: 'Reason To view Shopper detail', documentation: { example: 'For Substitution' }
            requires :order_id, type: Integer, desc: 'Id of the Order', documentation: { example: 12345670986 }
          end

          post '/shopper_detail_reason' do
            error!(CustomErrors.instance.not_allowed, 421) unless current_employee
            order = Order.select(:id).find_by_id(params[:order_id])
            error!(CustomErrors.instance.order_not_found, 421) unless order
            order_data = OrdersDatum.find_or_initialize_by(order_id: order.id)
            order_data.detail = order_data.detail.merge({"shopper_detail_reason" => params[:reason]})
            order_data.save!
            { message: 'ok' }
          end
        end
      end
    end
  end
end