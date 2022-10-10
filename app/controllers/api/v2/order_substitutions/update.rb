# frozen_string_literal: true

module API
  module V2
    module OrderSubstitutions
      class Update < Grape::API
        include ResponseStatuses
        include TokenAuthenticable
        helpers Concerns::SmilesHelper
        version 'v2', using: :path
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
            adyen_order = order.payment_type_id == 3 && order.card_detail['ps'].to_s.eql?('adyen')
            smiles_order = order.payment_type_id == 4
            resulting_array = []
            total_value = 0
            products.each do |product|
              order_substitution = {
                order_id: order.id,
                product_id: product[:product_id],
                substituting_product_id: product[:substituting_product_id]
              }
              order_substitution = order.order_substitutions.find_by(order_substitution)
              if order_substitution.present?

                order_position = order.order_positions.find_by(product_id: order_substitution.product_id)
                next unless order_position.present?

                order_substitution.selected(order_position, request.headers['Datetimeoffset'])
                if adyen_order || smiles_order
                  result = order_position.update_position(order_substitution.substituting_product_id, product[:amount],
                                                          order.retailer_id, order_substitution.shop_promotion_id,
                                                          request.headers['Datetimeoffset'])
                  next unless result.is_a?(Array)

                  total_value += ((order_position.shop_price_dollars + (order_position.shop_price_cents / 100.0)) * product[:amount]).round(2)
                  resulting_array << { order_position: order_position, shop: result[0], with_stock: result[1], amount: product[:amount] }
                else
                  order_position.replace_position(order_substitution.substituting_product_id, product[:amount],
                                                  order.retailer_id, order_substitution.shop_promotion_id,
                                                  request.headers['Datetimeoffset'])
                end
              elsif (proposal = ProductProposal.find_by(order_id: order.id, product_id: product[:substituting_product_id]))
                order_substitution = OrderSubstitution.find_by(order_id: order.id, product_id: product[:product_id], product_proposal_id: proposal.id)
                order_position = order.order_positions.find_by(product_id: order_substitution.product_id)
                next unless order_position.present?

                order_substitution.selected(order_position, request.headers['Datetimeoffset'])
                if adyen_order
                  result = order_position.update_proposal_position(proposal, product[:amount], request.headers['Datetimeoffset'])
                  next unless result.is_a?(Array)

                  total_value += ((order_position.shop_price_dollars + (order_position.shop_price_cents / 100.0)) * product[:amount]).round(2)
                  resulting_array << { order_position: order_position, shop: result[0], with_stock: result[1], amount: product[:amount] }
                else
                  order_position.replace_proposal_position(proposal, product[:amount], request.headers['Datetimeoffset'])
                end
              else
                next
              end
            end
            check_and_adjust(adyen_order, order, total_value)
            update_debit_smiles_points(order, (order.total_price + total_value)) if smiles_order
            update_positions(resulting_array)
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

        resource :order_substitutions do
          desc 'Allows Update order substitutions'
          params do
            requires :order_id, type: Integer, desc: 'Order ID', documentation: { example: 2 }
            requires :products, type: Array do
              requires :product_id, type: Integer, desc: 'Product ID being substituded', documentation: { example: '5' }
              requires :substituting_product_id, type: Integer, desc: 'Suggested substituting Product ID', documentation: { example: '5' }
              requires :amount, type: Integer, desc: 'Desired quantity/amount of product', documentation: { example: '5' }
            end
            optional :delivery_vehicle, type: Integer, desc: 'Delivery Vehicle ID', documentation: { example: 1 }
          end

          put '/update' do
            target_user = current_employee || current_retailer || current_shopper
            order = Order.find_by(id: params[:order_id])
            error!(CustomErrors.instance.order_not_found, 421) unless order
            adyen_order = order.payment_type_id == 3 && order.card_detail['ps'].to_s.eql?('adyen')
            smiles_order = order.payment_type_id == 4
            resulting_array = []
            total_value = 0
            products = params[:products]
            err_list = []
            products.each do |product|
              order_substitution = {
                order_id: order.id,
                product_id: product[:product_id],
                substituting_product_id: product[:substituting_product_id]
              }
              order_substitution = order.order_substitutions.find_by(order_substitution)
              if order_substitution.present?
                order_position = order.order_positions.find_by(product_id: order_substitution.product_id)
                next unless order_position.present?

                result =
                  if adyen_order || smiles_order
                    order_position.update_position(order_substitution.substituting_product_id, product[:amount],
                                                   order.retailer_id, order_substitution.shop_promotion_id,
                                                   request.headers['Datetimeoffset'])
                  else
                    order_position.replace_position(order_substitution.substituting_product_id, product[:amount],
                                                    order.retailer_id, order_substitution.shop_promotion_id,
                                                    request.headers['Datetimeoffset'])
                  end
              elsif (proposal = ProductProposal.find_by(order_id: order.id, product_id: product[:substituting_product_id]))
                order_substitution = OrderSubstitution.find_by(order_id: order.id, product_id: product[:product_id], product_proposal_id: proposal.id)
                order_position = order.order_positions.find_by(product_id: order_substitution.product_id)
                next unless order_position.present?

                result =
                  if adyen_order
                    order_position.update_proposal_position(proposal, product[:amount], request.headers['Datetimeoffset'])
                  else
                    order_position.replace_proposal_position(proposal, product[:amount], request.headers['Datetimeoffset'])
                  end
              else
                next
              end

              case result
              when Hash
                err_list << result
                next
              when Array
                total_value += ((order_position.shop_price_dollars + (order_position.shop_price_cents / 100.0)) * product[:amount]).round(2)
                resulting_array << { order_position: order_position, shop: result[0], with_stock: result[1], amount: product[:amount] }
                next
              end
              order_substitution.selected(order_position, request.headers['Datetimeoffset'])
            end

            error!(CustomErrors.instance.products_limited_stock(err_list), 421) unless err_list.blank?

            check_and_adjust(adyen_order, order, total_value)
            update_debit_smiles_points(order, (order.total_price + total_value)) if smiles_order
            update_positions(resulting_array)
            notify_shopper = current_shopper ? false : true
            order.mark_substituted(is_notify_shopper: notify_shopper, current_employee: current_employee ? true : false, delivery_vehicle: params[:delivery_vehicle])
            Analytic.add_activity("Substituted by #{target_user.class.name}", order)

            if current_employee
              EmployeeActivity.add_activity('Substitution Completed', current_employee.id, params[:order_id])
            end
            { message: 'ok' }
          end
        end

        helpers do
          def create_log(response, activity, owner)
            Analytic.post_activity("Adyen:#{activity}:#{SUCCESSFUL_HTTP_STATUS.include?(response.status) ? 'success' : 'failed'}", owner, detail: response.to_json, date_time_offset: request.headers['Datetimeoffset'])
            response
          end

          def check_and_adjust(adyen_order, order, total_value)
            return unless adyen_order && (order.total_price + total_value) > (order.card_detail['auth_amount'] / 100.0)

            response = Adyenps::Checkout.adjust_authorisation({ 'reference' => "O-#{order.card_detail['trans_ref']}-#{order.id}",
                                                                'originalReference' => order.merchant_reference,
                                                                'modificationAmount' => { currency: 'AED', value: ((order.total_price + total_value) * 100).round },
                                                                'adjustAuthorisationData' => order.orders_datum.detail['adjustAuthorisationData'] })
            create_log(response, 'SyncAuthorisationAdjustment', order)
            error!(CustomErrors.instance.payment_issue(response.response['message']), 421) unless SUCCESSFUL_HTTP_STATUS.include?(response.status)
            if response.response['response'].eql?('Authorised')
              order.card_detail['auth_amount'] = ((order.total_price + total_value) * 100).round
              order.save
              OrdersDatum.post_data(order.id, detail: { adjustAuthorisationData: response.response['additionalData']['adjustAuthorisationData'] })
            else
              error!(CustomErrors.instance.payment_issue(response.response['additionalData']['refusalReasonRaw']), 421)
            end
          end

          def update_positions(resulting_array)
            resulting_array.each do |res|
              OrderPosition.transaction do
                if res[:with_stock] && res[:shop]
                  shop = res[:shop]
                  shop.available_for_sale = shop.available_for_sale - res[:amount]
                  shop.is_available = false if shop.available_for_sale.zero?
                  shop.save
                end
                op = res[:order_position]
                op.save
              end
            end
          end
        end
      end
    end
  end
end
