# frozen_string_literal: true

module API
  module V1
    module PromotionCodes
      class List < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :promotion_codes do
          desc 'Checks promo code validity and creates promo code realization (returns promo code)'

          params do
            requires :retailer_id, type: Integer, desc: 'Retailer ID'
            requires :limit, type: Integer, desc: 'Limit of PromotionCode'
            requires :offset, type: Integer, desc: 'Offset of PromotionCode'
          end

          get '/list' do
            error!(CustomErrors.instance.shopper_not_found, 421) unless current_shopper
            orders = Order.where(shopper_id: current_shopper.id).where.not(status_id: 4).count
            list = PromotionCode.left_joins(:promotion_codes_retailers)
                                .where("end_date >= '#{Date.today}' AND start_date <= '#{Date.today}'")
                                .where("promotion_codes_retailers.retailer_id = #{params[:retailer_id]} OR all_retailers = true")
                                .where("#{current_shopper.id} = ANY (shopper_ids) OR (promotion_type NOT IN (4, 6) AND shopper_ids = '{}')")
                                .left_joins(:realizations)
                                .select('promotion_codes.*, count(promotion_code_realizations.id) FILTER (WHERE (promotion_code_realizations.order_id IS NOT NULL) AND (promotion_code_realizations.retailer_id IS NOT NULL) AND (promotion_code_realizations.promotion_code_id = promotion_codes.id)) AS overall_realization')
                                .select("count(promotion_code_realizations.id) FILTER (WHERE (promotion_code_realizations.order_id IS NOT NULL) AND (promotion_code_realizations.retailer_id IS NOT NULL) AND (promotion_code_realizations.promotion_code_id = promotion_codes.id) AND (promotion_code_realizations.shopper_id = #{current_shopper.id})) AS shoppers_realization")
                                .select("count(promotion_code_realizations.id) FILTER (WHERE (promotion_code_realizations.order_id IS NOT NULL) AND (promotion_code_realizations.retailer_id IS NOT NULL) AND (promotion_code_realizations.promotion_code_id = promotion_codes.id) AND (promotion_code_realizations.retailer_id = #{params[:retailer_id]})) AS retailers_realization")
                                .select("string_to_array(order_limit, '-') AS str_to_arr")
                                .group('promotion_codes.id')

            list = PromotionCode.includes(:brands).select('promo_code.*').from(list, :promo_code)
            list = list.where("((promo_code.allowed_realizations = 0) OR (promo_code.allowed_realizations > promo_code.overall_realization))
                                  AND ((promo_code.realizations_per_shopper = 0) OR (promo_code.realizations_per_shopper > promo_code.shoppers_realization))
                                  AND (( promo_code.realizations_per_retailer = 0) OR (promo_code.realizations_per_retailer > promo_code.retailers_realization))")
                       .where("(((cardinality(promo_code.str_to_arr) > 1) AND (#{orders} >= cast((promo_code.str_to_arr)[1] as int)) AND (#{orders} <= cast((promo_code.str_to_arr)[2] as int))) OR ((cardinality(promo_code.str_to_arr) < 1) AND #{orders} = cast(promo_code.order_limit as int)))")
                       .limit(params[:limit]).offset(params[:offset])
            # THEN tp_x3 ELSE tp_x2 END AS retailers_realization
            present list, with: API::V1::PromotionCodes::Entities::PromoCodesListEntity, retailer: Retailer.select(:id, :company_name, :company_name_ar).find_by(id: params[:retailer_id])
          end
        end
      end
    end
  end
end
