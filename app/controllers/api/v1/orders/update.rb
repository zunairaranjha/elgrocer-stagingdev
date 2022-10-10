# frozen_string_literal: true

module API
  module V1
    module Orders
      class Update < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :orders do
          desc 'Allows Edit of an order', entity: API::V1::Orders::Entities::ShowEntity
          params do
            requires :order_id, type: Integer, desc: 'Order Id'
            optional :delivery_slot_id, type: Integer, desc: 'if scheduled delivery order'
            optional :wallet_amount_paid, type: Float, desc: 'Amount paid From Wallet'
            optional :promotion_code_realization_id, type: Integer, desc: 'ID of the promotion code realization'
            optional :shopper_note, type: String, desc: 'Shopper note for retailer'
            requires :retailer_id, type: Integer, desc: 'ID of the retailer', documentation: { example: 16 }
            requires :shopper_address_id, type: Integer, desc: "ID of the shopper's address", documentation: { example: 16 }
            requires :payment_type_id, type: Integer, desc: 'ID of the payment type', documentation: { example: 2 }
            requires :products, type: Array do
              requires :amount, type: Integer, desc: 'Desired amount of product', documentation: { example: '5' }
              requires :product_id, type: Integer, desc: 'Desired amount of product', documentation: { example: '5' }
            end
            optional :service_fee, type: Float, desc: 'Retailer Service fee'
            optional :delivery_fee, type: Float, desc: 'Delivery fee'
            optional :rider_fee, type: Float, desc: 'Rider Service fee'
            optional :vat, type: Integer, desc: 'Value Added TAX %'
            optional :device_type, type: Integer, desc: "Shopper's device type (0 - Android, 1 - IOS, 2 - Web)"
            optional :recipe_id, type: Integer, desc: 'Recipe Id', documentation: { example: 4 }
            optional :card_id, type: Integer, desc: 'Credit Card ID', documentation: { example: '5' }
            optional :merchant_reference, type: String, desc: 'Merchant Reference Number', documentation: { example: '0454567807' }
            optional :auth_amount, type: Integer, desc: 'Authorized Amount', documentation: { example: 1000 }
            optional :week, type: Integer, desc: 'Week of the year for which order is being placed', documentation: { example: 14 }
            optional :realization_present, type: Boolean, desc: 'Is Realization Present or not', documentation: { example: 'true' }
          end

          put '/update' do
            target_user = current_retailer || current_shopper
            if target_user.class.name.downcase.eql?('retailer')
              error!({ error_code: 401, error_message: "Only shopper's can edit orders!" }, 401)
            else
              order = Order.find_by(id: params[:order_id])
              if order
                params[:week] = params[:week].to_i - 60 if params[:week].to_i > 59
                result = ::Orders::Update.run(params.merge(shopper_id: target_user.id, language: I18n.locale.to_s))
                if result.valid?
                  ::SlackNotificationJob.perform_later(result.result.id)
                  # ::PartnerIntegrationJob.perform_later(result.result.id) # send order details to partner
                  order = Order.includes({ order_positions: [:product] }, { promotion_code_realization: [:promotion_code] }, { retailer: [:available_payment_types, :city] }, :delivery_slot, :retailer_delivery_zone, { order_substitutions: [substituting_product: :brand] }).find(result.result.id)
                  present order, with: API::V1::Orders::Entities::ShowEntity
                else
                  error_code = 10_000

                  if result.errors[:order_value_is_not_enough].present?
                    error_code = 10_002
                  elsif result.errors[:location_is_not_covered].present?
                    error_code = 10_003
                  elsif result.errors[:retailer_is_opened].present?
                    error_code = 10_004
                  elsif result.errors[:promocode_invalid].present?
                    error_code = 10_005
                  elsif result.errors[:promocode_invalid_brands].present?
                    error_code = 10_006
                  elsif result.errors[:retailer_id].present?
                    error_code = 10_001
                  elsif result.errors[:wallet_amount_is_not_enough].present?
                    error_code = 10_008
                  elsif result.errors[:order_is_cancelled].present?
                    error_code = 10_040
                  end

                  error_code = 10_009 if result.errors[:delivery_slot_invalid].present?
                  # error_code = 10_010 if result.errors[:delivery_slot_orders_limit].present?
                  error_code = 10_011 if result.errors[:delivery_slot_id].present?
                  error_code = 10_010 if result.errors[:delivery_slot_products_limit].present?

                  error!({ error_code: error_code, error_message: result.errors }, 422)
                end
              else
                error!({ error_code: 10000, error_message: 'Order not found' }, 422)
              end
            end
          end
        end
      end
    end
  end
end
