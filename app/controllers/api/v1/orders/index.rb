module API
  module V1
    module Orders
      class Index < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :orders do
          desc "lists all orders of a shopper or retailer (depending on who is requesting it)", entity: API::V1::Orders::Entities::ShowEntity
          params do
            optional :status_id, type: String, desc: 'Order status ID'
            optional :retailer_id, type: Integer, desc: 'Store ID'
            optional :limit, type: Integer, desc: 'Limit of orders', documentation: { example: 20 }
            optional :offset, type: Integer, desc: 'Offset of orders', documentation: { example: 10 }
            optional :time, type: Integer, desc: 'Time for Check new Order', documentation: { example: 1565879977 }
            optional :order_ids, type: String, desc: 'Ids of order', documentation: { example: '123434,132323,2345689'}
          end
      
          get do
            target_user = current_retailer || current_shopper
            if params[:retailer_id]
              orders = []
            else
              if target_user.class.name.downcase.eql?("retailer")
                orders = target_user.orders.includes(:credit_card, {order_positions: :product}, {promotion_code_realization: [:promotion_code]}, :delivery_slot, {order_substitutions: [substituting_product: :brand]}, {analytics: :event})
                orders = orders.where(retailer_deleted: false)
                orders = orders.where(id: params[:order_ids].split(',').reject(&:empty?).map(&:to_i)) if params[:order_ids].present?
              else
                orders = target_user.orders.includes(:credit_card, {order_positions: :product}, {promotion_code_realization: [:promotion_code]}, {retailer: [:available_payment_types, :city]}, :delivery_slot, :retailer_delivery_zone, order_substitutions: [substituting_product: :brand])
                orders = orders.where(shopper_deleted: false)
              end
              orders = orders.where.not(retailer_id: nil)
              orders = orders.where(status_id: params[:status_id].to_s.scan(/\d+/)) if params[:status_id]
              orders = orders.where(retailer_id: params[:retailer_id]) if params[:retailer_id]
              if target_user.class.name.downcase.eql?("retailer") && params[:time]
                orders = orders.where("orders.status_id = 0 and orders.created_at >= '#{Time.at(params[:time])}'").where("orders.estimated_delivery_at <= '#{Time.now + target_user.show_pending_order_hours.hours}'")
              elsif target_user.class.name.downcase.eql?("retailer")
                orders = orders.where("((orders.status_id = 0 and estimated_delivery_at <= '#{Time.now + target_user.show_pending_order_hours.hours}') or orders.status_id in (1,6)) or (orders.status_id in (2,7) and orders.estimated_delivery_at >= '#{2.days.ago}') or (orders.status_id not in (0,1,2,6,7) and orders.estimated_delivery_at >= '#{6.hours.ago}')")
              elsif target_user.class.name.downcase.eql?("shopper")
                orders = orders.limit(10).offset(0)
              end
              # orders = orders.limit(10).offset(0) if target_user.class.name.downcase.eql?("shopper")
              orders = orders.limit(params[:limit]).offset(params[:offset]) if params[:limit] && params[:offset]
              orders = orders.order('orders.created_at DESC')
            end
      
            # if Rails.env.test?
            #   present orders, with: API::V1::Orders::Entities::ShowEntity, retailer: current_retailer
            # else
            #   orders_cached = Rails.cache.fetch([params.merge(orders_updated_at: "#{orders.maximum('orders.updated_at')}"),__method__], expires_in: 2.hours) do
            #     orders.to_a
            #   end
            #   present orders_cached, with: API::V1::Orders::Entities::ShowEntity, retailer: current_retailer
            # end
            retailer = target_user.class.name.downcase.eql?("retailer") ? target_user : nil
            present orders, with: API::V1::Orders::Entities::ShowEntity, retailer: retailer, v1: true
          end
      
          desc "lists all orders of a shopper or retailer (depending on who is requesting it)", entity: API::V1::Orders::Entities::ShowEntity
          params do
            optional :status_id, type: String, desc: 'Order status ID'
            optional :retailer_id, type: Integer, desc: 'Store ID'
            optional :limit, type: Integer, desc: 'Limit of orders', documentation: { example: 20 }
            optional :offset, type: Integer, desc: 'Offset of orders', documentation: { example: 10 }
            optional :time, type: Integer, desc: 'Time for Check new Order', documentation: { example: 1565879977 }
          end
      
          get '/list' do
            target_user = current_retailer || current_shopper
            if target_user.class.name.downcase.eql?("retailer")
              orders = target_user.orders.where(retailer_deleted: false)
            else
              orders = target_user.orders.where(shopper_deleted: false)
            end
            orders = orders.where.not(retailer_id: nil)
            orders = orders.where(status_id: params[:status_id].to_s.scan(/\d+/)) if params[:status_id]
            orders = orders.where(retailer_id: params[:retailer_id]) if params[:retailer_id]
            if target_user.class.name.downcase.eql?("retailer") && params[:time]
              orders = orders.where("orders.status_id = 0 and orders.created_at >= '#{Time.at(params[:time])}'").where("orders.estimated_delivery_at <= '#{Time.now + target_user.show_pending_order_hours.hours }'")
            elsif target_user.class.name.downcase.eql?("retailer")
              orders = orders.where("((orders.status_id = 0 and estimated_delivery_at <= '#{Time.now + target_user.show_pending_order_hours.hours }') or orders.status_id in (1,6)) or (orders.status_id in (2,7) and orders.estimated_delivery_at >= '#{2.days.ago}') or (orders.status_id not in (0,1,2,6,7) and orders.estimated_delivery_at >= '#{6.hours.ago}')")
            elsif target_user.class.name.downcase.eql?("shopper")
              orders = orders.limit(10).offset(0)
            end
            # orders = orders.limit(10).offset(0) if target_user.class.name.downcase.eql?("shopper")
            orders = orders.joins("join order_positions on order_positions.order_id = orders.id").select("orders.*, COALESCE(sum(case when order_positions.was_in_shop = 't' then order_positions.amount end), 0) AS total_products")
            orders = orders.group("orders.id")
            orders = orders.order('orders.estimated_delivery_at ASC, orders.id')
            orders = orders.limit(params[:limit]).offset(params[:offset]) if params[:limit] && params[:offset]
      
             orders_cached = Rails.cache.fetch([params.merge(orders_updated_at: "#{orders.maximum('orders.updated_at')}", target_user: target_user.id).except(:ip_address),__method__], expires_in: 10.minutes) do
               orders = orders.includes(:delivery_slot, {analytics: :event}, {promotion_code_realization: [:promotion_code]}) if target_user.class.name.downcase.eql?("retailer")
               orders.to_a
             end
      
            retailer = target_user.class.name.downcase.eql?("retailer") ? target_user : nil
            present orders_cached, with: API::V1::Orders::Entities::ListEntity, retailer: retailer, v1: true
          end
        end
      end      
    end
  end
end