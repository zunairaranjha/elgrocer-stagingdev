module API
  module V1
    module Orders
      class Recent < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :orders do
          desc "lists recent orders", entity: API::V1::Orders::Entities::RecentEntity
          params do
            optional :status_id, type: Integer, desc: 'Order status ID'
            optional :page, type: Integer, desc: 'Page'
          end
      
          get '/recent' do
            orders = Order.where(retailer_deleted: false).where(shopper_deleted: false).where("orders.created_at >= '#{1.day.ago}'")
            orders = orders.where.not(retailer_id: nil)
            orders = orders.where(status_id: params[:status_id]) if params[:status_id]
            orders = orders.includes(:order_positions, :promotion_code_realization, :delivery_slot)
            orders = orders.order('created_at DESC')
            orders = orders.page(params[:page].to_i).per(9)
      
            orders_cached = Rails.cache.fetch([params.merge(orders_updated_at: "#{orders.maximum('orders.updated_at')}").except(:ip_address),__method__], expires_in: 2.hours) do
              orders.to_a
            end
            present orders_cached, with: API::V1::Orders::Entities::RecentEntity
          end
        end
      end      
    end
  end
end