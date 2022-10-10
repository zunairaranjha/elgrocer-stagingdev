# frozen_string_literal: true

module API
  module V1
    module Orders
      class Create < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :orders do
          desc 'Allows creation of an order', entity: API::V1::Orders::Entities::ShowEntity
          params do
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
          end

          post do
            target_user = current_retailer || current_shopper
            if target_user.class.name.downcase.eql?('retailer')
              error!({ error_code: 401, error_message: "Only shopper's can create orders!" }, 401)
            else
              params[:week] = params[:week].to_i - 60 if params[:week].to_i > 59
              result = ::Orders::Create.run(params.merge(shopper_id: target_user.id, language: I18n.locale.to_s, app_version: request.headers['App-Version']))

              if result.valid?
                if result.result.status_id == 0
                  ShopperMailer.order_placement(result.result.id).deliver_later
                  ::ShopperCartProducts::Delete.run({ retailer_id: params.retailer_id, shopper_id: current_shopper.id }) rescue ''
                end
                ::SlackNotificationJob.perform_later(result.result.id)
                Resque.enqueue(PartnerIntegrationJob, result.result.id) # send order details to partner
                # ShopperMailer.new_order_placement(result.result.shopper_id).deliver_later
                # SmsNotificationJob.perform_later(result.result.shopper_phone_number.phony_normalized ,  I18n.t("sms.order_placement", retailer_name: result.result.retailer_company_name) ) if result.result.device_type == "android"
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
                end

                error_code = 10_009 if result.errors[:delivery_slot_invalid].present?
                # error_code = 10_010 if result.errors[:delivery_slot_orders_limit].present?
                error_code = 10_011 if result.errors[:delivery_slot_id].present?
                error_code = 10_010 if result.errors[:delivery_slot_products_limit].present?

                error!({ error_code: error_code, error_message: result.errors }, 422)
              end
            end
          end
        end
      end
    end
  end
end
