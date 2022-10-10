# frozen_string_literal: true

module API
  module V1
    module PromotionCodes
      class Create < Grape::API
        version 'v1', using: :path
        format :json

        resource :promotion_codes do
          desc 'This API will create the promotion code'

          params do
            optional :code, type: String, desc: 'The Unique Promotion Code', documentation: { example: 'code' }
            requires :value, type: Float, desc: 'The Max value off', documentation: { example: 10.0 }
            requires :min_basket_value, type: Float, desc: 'The Min Basket to apply promotion Code', documentation: { example: 100.0 }
            optional :start_date, type: String, desc: 'Starting time of the code', documentation: { example: '2021-08-01' }
            optional :end_date, type: String, desc: 'Ending time of the code', documentation: { example: '2021-08-31' }
            optional :percentage_off, type: Float, desc: 'The percentage off value', documentation: { example: 10 }
            optional :allowed_realizations, type: Integer, desc: 'The number of times Code can be used', documentation: { example: 1 }
            optional :realizations_per_shopper, type: Integer, desc: 'Number of times Shopper Can apply the code', documentation: { example: 1 }
            optional :realizations_per_retailer, type: Integer, desc: 'Number of times retailer can accept the code', documentation: { example: 1 }
            optional :order_limit, type: String, desc: 'No of order require to use code', documentation: { example: '0-1000' }
            optional :service_id, type: Integer, desc: 'Service at which code can apply', documentation: { example: 0 }
            optional :payment_type_ids, type: String, desc: 'On which payment types code can be used', documentation: { example: '1,2,3' }
            optional :retailer_ids, type: String, desc: 'List of retailer ids that accept promotion', documentation: { example: '16,211' }
            optional :brand_ids, type: String, desc: 'List of brand ids only on which code is applied', documentation: { example: '355,899' }
            optional :currency, type: String, desc: 'Currency', documentation: { example: 'AED' }
            optional :shopper_ids, type: String, desc: 'Shopper Ids', documentation: { example: '20,35099' }
            optional :reference, type: String, desc: 'Promotion Code Reference for reporting purpose', documentation: { example: 'Smiles_2021_12' }
          end

          post do
            error!(CustomErrors.instance.unauthorized, 421) unless request.headers['Access-Token'] == 'IK7RVgpTud7G2wTLXmo47veYlMViRo8ewUHTSfwyZOA'
            error!(CustomErrors.instance.value_must_be_greater, 421) unless params[:value] > 0.0
            start_date = params[:start_date].to_s.to_date
            end_date = params[:end_date].to_s.to_date
            code = params[:code].present? && params[:code] || PromotionCode.generate_code
            error!(CustomErrors.instance.end_must_be_greater, 421) if start_date && end_date && start_date >= end_date
            start_date ||= Time.now.to_date
            end_date ||= (Time.now + (SystemConfiguration.find_by_key('promotion_days')&.value || 30).to_i.day).to_date
            promo_code = PromotionCode.where('code ILIKE ? ', code).exists?
            error!(CustomErrors.instance.promo_code_exist, 421) if promo_code
            promo_code = PromotionCode.new(code: code, value_cents: params[:value] * 100, min_basket_value: params[:min_basket_value], start_date: start_date, end_date: end_date)
            attr = {
              'percentage_off' => params[:percentage_off],
              'allowed_realizations' => params[:allowed_realizations],
              'realizations_per_shopper' => params[:realizations_per_shopper],
              'realizations_per_retailer' => params[:realizations_per_retailer],
              'order_limit' => params[:order_limit],
              'retailer_service_id' => params[:service_id],
              'value_currency' => params[:currency],
              'reference' => params[:reference]
            }
            attr['shopper_ids'] = params[:shopper_ids].to_s.scan(/\d+/) if params[:shopper_ids].present?
            attr['all_retailers'] = true unless params[:retailer_ids].present?
            attr['all_brands'] = true unless params[:brand_ids].present?
            promo_code.assign_attributes(attr.compact)
            PromotionCode.transaction do
              promo_code.save
              payment_types = if params[:payment_type_ids].present?
                                params[:payment_type_ids].to_s.scan(/\d+/)
                              else
                                AvailablePaymentType.all.ids
                              end
              create_payment_types(promo_code.id, payment_types)
              create_promotion_brands(promo_code.id, params[:brand_ids].to_s.scan(/\d+/)) if params[:brand_ids].present?
              create_promotion_retailers(promo_code.id, params[:retailer_ids].to_s.scan(/\d+/)) if params[:retailer_ids].present?
            end
            if promo_code.persisted?
              present promo_code.attributes.except('all_brands', 'all_retailers')
            else
              error!(CustomErrors.instance.something_wrong, 421)
            end
          end
        end

        helpers do
          def create_payment_types(promo_id, payment_type_ids)
            values = payment_type_ids.map { |u| "(#{promo_id},#{u})" }.join(',')
            ActiveRecord::Base.connection.execute("INSERT INTO promotion_code_available_payment_types (promotion_code_id, available_payment_type_id) VALUES #{values}")
          end

          def create_promotion_brands(promo_id, brand_ids)
            values = brand_ids.map { |u| "(#{promo_id},#{u})" }.join(',')
            ActiveRecord::Base.connection.execute("INSERT INTO brands_promotion_codes (promotion_code_id, brand_id) VALUES #{values}")
          end

          def create_promotion_retailers(promo_id, retailer_ids)
            values = retailer_ids.map { |u| "(#{promo_id},#{u})" }.join(',')
            ActiveRecord::Base.connection.execute("INSERT INTO promotion_codes_retailers (promotion_code_id, retailer_id) VALUES #{values}")
          end
        end
      end
    end
  end
end
