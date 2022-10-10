# frozen_string_literal: true

module API
  module V3
    module PromotionCodes
      class CreateRealization < Grape::API
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
            requires :delivery_time, type: Float, desc: 'Delivery Time', documentation: { example: 1234567890000 }
            optional :order_id, type: Integer, desc: 'Order id In Edit Order Case', documentation: { example: 243567890 }
          end

          post '/create_realization' do
            if current_shopper
              result = ::PromotionCodes::CreateRealization.run(params.merge(
                                                                 shopper_id: current_shopper.id,
                                                                 service_id: request.headers['Service-Id'],
                                                                 date_time_offset: request.headers['Datetimeoffset']))
              if result.valid?
                present result.result
              else
                if result.errors[:retailer_id].present?
                  error!({ error_code: 10_017, error_message: result.errors[:retailer_id].first }, 422)
                elsif result.errors[:promocode_is_invalid].present?
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
