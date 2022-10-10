# frozen_string_literal: true

module API
  module V2
    module Orders
      class Tracking < Grape::API
        include TokenAuthenticable
        version 'v2', using: :path
        format :json
      
        resource :orders do
          desc "lists pending orders of a shopper" #, entity: API::V1::Orders::Entities::ShowEntity
          params do
            optional :retailer_id, type: Integer, desc: 'Retailer ID'
          end
      
          get '/tracking' do
            target_user = current_retailer || current_shopper
      
            orders = target_user.orders.select(:id,:created_at,:status_id,:retailer_id,:retailer_company_name, :delivery_slot_id)
            orders = orders.where('status_id < 3')
            orders = orders.where("(created_at >= '#{1.day.ago}' and delivery_slot_id is null) or (created_at >= '#{3.day.ago}' and delivery_slot_id>0)")
            orders = orders.where(retailer_id: params[:retailer_id]) unless params[:retailer_id].blank?
            orders = orders.order('updated_at DESC')
      
            # {orders: orders}
          end
        end
      end
    end
  end
end