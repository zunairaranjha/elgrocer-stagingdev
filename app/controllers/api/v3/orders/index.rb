module API
  module V3
    module Orders
      class Index < Grape::API
        include TokenAuthenticable
        version 'v3', using: :path
        format :json

        resource :orders do
          desc 'List of orders allocated to employee'

          params do
            requires :limit, type: Integer, desc: 'Limit of orders', documentation: { example: 20 }
            requires :offset, type: Integer, desc: 'Offset of orders', documentation: { example: 10 }
            optional :status_id, type: String, desc: 'Order status ID'
            optional :retailer_id, type: Integer, desc: 'Retailer ID', documentation: { example: 16 }
            optional :time, type: Integer, desc: 'Time for Check new Order', documentation: { example: 1565879977 }
            optional :allocated_to_me, type: Boolean, desc: 'To get allocated orders for a supervisor', documentation: { example: true }
          end

          get '/list' do
            if current_employee
              params[:status_id] = params[:status_id].to_s.scan(/\d+/)
              complete_status = (params[:status_id] & %w[2 11]).any?
              if !((current_employee.active_roles & [4, 5]).blank? || params[:allocated_to_me]) || complete_status
                params[:retailer_id] ||= current_employee.retailer_id
                orders = Order.where(retailer_deleted: false, retailer_id: params[:retailer_id])
                orders = orders.joins("LEFT OUTER JOIN order_allocations ON order_allocations.order_id = orders.id AND order_allocations.is_active = 't'")
              else
                params[:retailer_id] = current_employee.retailer_id
                orders = Order.joins("JOIN order_allocations ON order_allocations.order_id = orders.id AND order_allocations.is_active = 't' AND order_allocations.employee_id = #{current_employee.id}")
                orders = orders.where(retailer_deleted: false, retailer_id: params[:retailer_id])
              end
            else
              error!(CustomErrors.instance.update_to_latest, 421)
            end
            if params[:time]
              orders = orders.where("orders.status_id = 0 and orders.created_at >= '#{Time.at(params[:time])}'").where("orders.estimated_delivery_at <= '#{Time.now + 6.hours}'")
            elsif current_employee
              orders = orders.where("estimated_delivery_at between '#{Time.now - 40.week}' and '#{Time.now + Retailer.select(:show_pending_order_hours).find_by(id: params[:retailer_id])&.show_pending_order_hours.to_i.hours}'")
            end
            orders = orders.where.not(retailer_id: nil)
            orders = orders.where(status_id: params[:status_id])
            orders = orders.joins('LEFT OUTER JOIN employees ON employees.id = order_allocations.employee_id')
            orders = orders.joins('LEFT JOIN delivery_slots ON delivery_slots.id = orders.delivery_slot_id')
            orders = orders.joins('JOIN order_positions on order_positions.order_id = orders.id')
            orders = orders.select("orders.*, COALESCE(sum(case when order_positions.was_in_shop = 't' then order_positions.amount end), 0) AS total_products, (ARRAY_AGG(employees.user_name))[1:1] AS employee_name")
            orders = orders.group('delivery_slots.id, orders.id')
            orders = if complete_status
                       orders.order('orders.estimated_delivery_at DESC, orders.id')
                     else
                       orders.order('orders.estimated_delivery_at, delivery_slots.end')
                     end
            orders = orders.limit(params[:limit]).offset(params[:offset]) if params[:limit] && params[:offset]
            orders_cached = Rails.cache.fetch([params.merge(
              orders_updated_at: orders.maximum('orders.updated_at - COALESCE(order_allocations.created_at, orders.created_at)').to_s,
              retailer_id: params[:retailer_id]
            ), __method__], expires_in: 10.minutes) do
              orders = orders.includes(:delivery_slot, :collector_detail, :pickup_loc, :orders_datum, :delivery_channel,
                                       analytics: :event, promotion_code_realization: [:promotion_code],
                                       vehicle_detail: %i[color vehicle_model])
              orders.to_a
            end
            # TODO: Remove the condition once we are prepared to go live fully to enable check for all retailers
            if DRIVER_PILOT_RETAILER_IDS.include?(params[:retailer_id])
              locus_integration = PartnerIntegration.where(integration_type: %w[locus_post_order locus_batch_post_order]).where(retailer_id: params[:retailer_id])
            end
            locus_integration ||= []

            API::V3::Orders::Entities::PickerOrderEntity.represent orders_cached, root: false, retailer: true, locus_integration: locus_integration
          end

          desc 'Order History of a Shopper'

          params do
            requires :limit, type: Integer, desc: 'Limit of orders', documentation: { example: 20 }
            requires :offset, type: Integer, desc: 'Offset of orders', documentation: { example: 10 }
          end

          get '/history' do
            if current_shopper
              orders = current_shopper.orders.where(shopper_deleted: false)
            else
              error!(CustomErrors.instance.update_to_latest, 421)
            end
            # service_id = request.headers['Service-Id'] || 1
            orders = orders.where.not(retailer_id: nil)
            # orders = orders.where(retailer_service_id: service_id.to_i)
            orders = orders.joins('join order_positions on order_positions.order_id = orders.id')
            orders = orders.joins('join products on products.id = order_positions.product_id')
            orders = orders.joins('join retailers on retailers.id = orders.retailer_id')
            orders = orders.select("orders.*, COALESCE(sum(case when order_positions.was_in_shop = 't' then order_positions.amount end), 0) AS total_products")
            orders = orders.select("(ARRAY_AGG(format('%s/%s/%s/%s/medium/%s,:%s,:%s,:%s,:%s,:%s','https://s3-eu-west-1.amazonaws.com/elgrocerstaging/products/photos',left(lpad(products.id::text,9, '0'),3), left(right(lpad(products.id::text,9, '0'),6),3), right(lpad(products.id::text,9, '0'),3), products.photo_file_name, order_positions.was_in_shop::text, order_positions.amount, products.id, (order_positions.shop_price_dollars + order_positions.shop_price_cents/100.0), order_positions.promotional_price)))[1:6] AS positions_data")
            orders = orders.select("format('%s/%s/%s/%s/medium/%s','https://s3-eu-west-1.amazonaws.com/elgrocerstaging/retailers/photos',left(lpad(retailers.id::text,9, '0'),3), left(right(lpad(retailers.id::text,9, '0'),6),3), right(lpad(retailers.id::text,9, '0'),3), retailers.photo_file_name) AS retailer_photo, orders.retailer_delivery_zone_id, retailers.delivery_type_id AS retailer_delivery_type_id, retailers.is_opened AS retailer_opened")
            orders = orders.group('orders.id, retailers.id')
            orders = orders.order('orders.created_at DESC, orders.id')
            orders = orders.limit(params[:limit]).offset(params[:offset]) if params[:limit] && params[:offset]

            orders_cached = Rails.cache.fetch([params.merge(orders_updated_at: orders.where("orders.created_at >= '#{1.day.ago}'").except(:order, :group).maximum('orders.updated_at').to_s, shopper_id: current_shopper.id, service_id: 'history'), __method__], expires_in: 24.hours) do
              orders = orders.includes(:delivery_slot, :credit_card, promotion_code_realization: [:promotion_code])
              orders = orders.includes(:collector_detail, :pickup_loc, vehicle_detail: %i[color vehicle_model])
              orders.to_a
            end
            API::V3::Orders::Entities::ShopperOrderHistory.represent orders_cached, root: false
          end
        end
      end
    end
  end
end
