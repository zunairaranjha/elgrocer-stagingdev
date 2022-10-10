# frozen_string_literal: true

module API
  module V3
    module PromotionCodes
      class CheckAndRealize < Grape::API
        include TokenAuthenticable
        version 'v3', using: :path
        format :json

        resource :promotion_codes do
          desc 'Checks promo code validity and creates promo code realization (returns promo code)'

          params do
            requires :payment_type_id, type: Integer, desc: 'ID of the payment type', documentation: { example: 2 }
            requires :promo_code, type: String, desc: 'Recived promotion code'
            requires :retailer_id, type: Integer, desc: 'ID of the retailer'
            requires :products, type: Array do
              requires :amount, type: Integer, desc: 'Desired amount of product', documentation: { example: '5' }
              requires :product_id, type: Integer, desc: 'Desired product id', documentation: { example: '5' }
            end
            optional :service_fee, type: Float, desc: 'Service Fee of the retailer', documentation: { example: 9.0 }
            optional :delivery_fee, type: Float, desc: 'Delivery Fee', documentation: { example: 1.0 }
            optional :rider_fee, type: Float, desc: 'Rider fee', documentation: { example: 9.0 }
          end

          post '/check_and_realize' do
            if current_shopper
              result = ::PromotionCodes::V2CheckAndRealize.run(params.merge(
                                                                 shopper_id: current_shopper.id,
                                                                 service_id: request.headers['Service-Id'],
                                                                 date_time_offset: request.headers['Datetimeoffset']))
              if result.valid?
                # if result.result.present?
                present result.result
                # else
                #   error!({ error_code: 10_005, error_message: ['Invalid promotion code'] }, 422)
                # end
              else
                if result.errors[:promocode_is_invalid].present?
                  error!({ error_code: 10_005, error_message: result.errors[:promocode_is_invalid].first }, 422)
                elsif result.errors[:not_for_shopper].present?
                  error!({ error_code: 10_015, error_message: result.errors[:not_for_shopper].first }, 422)
                elsif result.errors[:already_used].present?
                  error!({ error_code: 10_014, error_message: result.errors[:already_used].first }, 422)
                elsif result.errors[:promocode_expired].present?
                  error!({ error_code: 10_010, error_message: result.errors[:promocode_expired].first }, 422)
                elsif result.errors[:not_for_service].present?
                  error!({ error_code: 10_016, error_message: result.errors[:not_for_service].first }, 422)
                elsif result.errors[:payment_type_invalid].present?
                  error!({ error_code: 10_009, error_message: result.errors[:payment_type_invalid].first }, 422)
                elsif result.errors[:not_for_retailer].present?
                  error!({ error_code: 10_013, error_message: result.errors[:not_for_retailer].first }, 422)
                elsif result.errors[:max_allowed_realizations].present?
                  error!({ error_code: 10_012, error_message: result.errors[:max_allowed_realizations].first }, 422)
                elsif result.errors[:promotion_invalid_brands].present?
                  error!({ error_code: 10_007, error_message: result.errors[:promotion_invalid_brands].first }, 422)
                elsif result.errors[:order_value_is_not_enough_for_realize].present?
                  error!({ error_code: 10_002, error_message: result.errors[:order_value_is_not_enough_for_realize].first }, 422)
                elsif result.errors[:orders_limit_not_matched].present?
                  error!({ error_code: 10_011, error_message: result.errors[:orders_limit_not_matched].first }, 422)
                end
                # error_code = 10_000
                # error_code = 10_009 if result.errors[:payment_type_invalid].present?
                # error_code = 10_007 if result.errors[:promotion_invalid_brands].present?
                # error_code = 10_005 if result.errors[:promocode_is_invalid].present?
                # error_code = 10_002 if result.errors[:order_value_is_not_enough].present?
                # #error_code = 10_008 if result.errors[:orders_limit_not_matched].present?
                # (result.errors[:orders_limit_not_matched].present? and error_code == 10_000) ? error!({error_code: 10_011, error_message: I18n.t("message.promo_order_limit")}, 422) : error!({error_code: error_code, error_message: result.errors}, 422)
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