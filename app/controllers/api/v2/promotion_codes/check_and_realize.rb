# frozen_string_literal: true

module API
  module V2
    module PromotionCodes
      class CheckAndRealize < Grape::API
        include TokenAuthenticable
        version 'v2', using: :path
        format :json

        resource :promotion_codes do
          desc "Checks promo code validity and creates promo code realization (returns promo code)",
               entity: API::V2::PromotionCodes::Entities::ShowPromoCodeEntity
          params do
            requires :payment_type_id, type: Integer, desc: "ID of the payment type", documentation: { example: 2 }
            requires :promo_code, type: String, desc: 'Recived promotion code'
            requires :retailer_id, type: Integer, desc: 'ID of the retailer'
            requires :products, type: Array do
              requires :amount, type: Integer, desc: "Desired amount of product", documentation: { example: "5" }
              requires :product_id, type: Integer, desc: "Desired product id", documentation: { example: "5" }
            end
            optional :service_fee, type: Float, desc: 'Service Fee of the retailer', documentation: { example: 9.0 }
            optional :delivery_fee, type: Float, desc: 'Delivery Fee', documentation: { example: 1.0 }
            optional :rider_fee, type: Float, desc: 'Rider fee', documentation: { example: 9.0 }
          end

          post '/check_and_realize' do
            if current_shopper
              result = ::PromotionCodes::CheckAndRealize.run(params.merge(shopper_id: current_shopper.id))
              if result.valid?
                if result.result.present?
                  present result.result
                else
                  error!({ error_code: 10_005, error_message: ['Invalid promotion code'] }, 422)
                end
              else
                error_code = 10_000
                error_code = 10_009 if result.errors[:payment_type_invalid].present?
                error_code = 10_007 if result.errors[:promotion_invalid_brands].present?
                error_code = 10_005 if result.errors[:promocode_is_invalid].present?
                error_code = 10_002 if result.errors[:order_value_is_not_enough].present?
                #error_code = 10_008 if result.errors[:orders_limit_not_matched].present?
                (result.errors[:orders_limit_not_matched].present? and error_code == 10_000) ? error!({ error_code: 10_011, error_message: I18n.t("message.promo_order_limit") }, 422) : error!({ error_code: error_code, error_message: result.errors }, 422)
              end
            else
              error!({ error_code: 10_000, error_message: result.errors }, 422)
            end
          end
        end
      end
    end
  end
end