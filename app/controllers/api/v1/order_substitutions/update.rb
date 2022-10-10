# frozen_string_literal: true

module API
  module V1
    module OrderSubstitutions
      class Update < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :order_substitutions do
          desc 'Allows creation of an order substitutions'
          params do
            requires :order_id, type: Integer, desc: 'Order ID', documentation: { example: 2 }
            requires :products, type: Array do
              requires :product_id, type: Integer, desc: 'Product ID being substituded', documentation: { example: '5' }
              requires :substituting_product_id, type: Integer, desc: 'Suggested substituting Product ID', documentation: { example: '5' }
              requires :amount, type: Integer, desc: 'Desired quantity/amount of product', documentation: { example: '5' }
            end
          end

          put do
            target_user = current_employee || current_retailer || current_shopper
            products = params[:products]
            order = Order.find(params[:order_id])
            products.each do |product|
              order_substitution = {
                order_id: order.id,
                product_id: product[:product_id],
                substituting_product_id: product[:substituting_product_id]
              }
              order_substitution = order.order_substitutions.find_by(order_substitution)
              next unless order_substitution.present?

              order_position = order.order_positions.find_by(product_id: order_substitution.product_id)
              order_substitution.selected(order_position, request.headers['Datetimeoffset'])

              # update order position
              # order_position = order.order_positions.find_by(product_id: order_substitution.product_id)
              next unless order_position.present?

              order_position.replace_position(order_substitution.substituting_product_id, product[:amount],
                                              order.retailer_id, order_substitution.shop_promotion_id,
                                              request.headers['Datetimeoffset'])
            end

            notify_shopper = current_shopper ? false : true
            order.mark_substituted(is_notify_shopper: notify_shopper, current_employee: current_employee ? true : false)
            Analytic.add_activity("Substituted by #{target_user.class.name}", order)
            # ::SlackNotificationJob.perform_later(order.id)

            if current_employee
              EmployeeActivity.add_activity('Substitution Completed', current_employee.id, params[:order_id])
              { message: 'ok' }
            elsif request.headers['Datetimeoffset'].present?
              { message: 'ok' }
            else
              present order, with: API::V1::Orders::Entities::ShowEntity
            end
          end
        end
      end
    end
  end
end
