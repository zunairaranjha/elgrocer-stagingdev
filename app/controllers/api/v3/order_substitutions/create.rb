# frozen_string_literal: true

module API
  module V3
    module OrderSubstitutions
      class Create < Grape::API
        include TokenAuthenticable
        version 'v3', using: :path
        format :json

        resource :order_substitutions do
          desc 'Allows creation of an order substitutions', entity: API::V1::OrderSubstitutions::Entities::ShowEntity
          params do
            requires :order_id, type: Integer, desc: 'Order ID', documentation: { example: 2 }
            requires :products, type: Array do
              requires :product_id, type: Integer, desc: 'Product ID being substituded', documentation: { example: '5' }
              optional :substituting_product_id, type: Integer, desc: 'Suggested substituting Product ID', documentation: { example: '5' }
              optional :product_proposal_id, type: Integer, desc: 'Proposed substituting Product ID', documentation: { example: '5' }
            end
          end

          post do
            error!(CustomErrors.instance.only_for_employee, 421) unless current_employee
            order = Order.find_by(id: params[:order_id])
            error!(CustomErrors.instance.order_already_in_substitution, 421) if order.status_id == 6
            order_substitutions = []
            products = params[:products]

            products.each do |product|
              order.order_positions.where(product_id: product[:product_id]).find_each { |m| m.update_attribute(:was_in_shop, false) }
              next unless product[:product_id].to_i.positive? && (product[:substituting_product_id].to_i.positive? || product[:product_proposal_id].to_i.positive?)

              order_substitution = {
                order_id: order.id,
                product_id: product[:product_id],
                shopper_id: order.shopper_id,
                retailer_id: order.retailer_id,
                shop_promotion_id: shop_promotion(order.retailer_id, product[:substituting_product_id], order.estimated_delivery_at)&.id,
                date_time_offset: request.headers['Datetimeoffset']
              }
              if product[:product_proposal_id].to_i.positive?
                order_substitution[:product_proposal_id] = product[:product_proposal_id]
              else
                order_substitution[:substituting_product_id] = product[:substituting_product_id]
              end
              order_substitutions.push(order_substitution)
            end
            OrderSubstitution.transaction do
              OrderSubstitution.create(order_substitutions)
              order.mark_substituting(from_employee: current_employee ? true : false)
            end
            Analytic.add_activity('Substitution suggested', order)
            if current_employee
              EmployeeActivity.add_activity('Substitution suggested', current_employee.id, params[:order_id])
              { message: 'ok' }
            else
              present order.order_substitutions, with: API::V1::OrderSubstitutions::Entities::ShowEntity, documentation: { type: 'order_substitution' }
            end
          end
        end

        helpers do
          def shop_promotion(retailer_id, product_id, delivery_time)
            ShopPromotion.where('retailer_id = ? AND product_id = ? AND ? BETWEEN start_time AND end_time', retailer_id, product_id, (delivery_time.to_time.utc.to_f * 1000).floor).first
          end
        end
      end
    end
  end
end
