# frozen_string_literal: true

module API
  module V2
    module Chefs
      class Index < Grape::API
        version 'v2', using: :path
        format :json

        resource :chefs do
          desc 'get list of chefs'

          params do
            requires :retailer_ids, type: String, desc: 'List of retailer idss', documentation: { example: '16,178' }
            optional :id, desc: 'ID of Chef', documentation: {example: 10}
            optional :limit, type: Integer, desc: 'Limit of Chefs', documentation: { example: 20 }
            optional :offset, type: Integer, desc: 'Offset of Chefs', documentation: { example: 10 }
          end

          get do
            error!(CustomErrors.instance.params_missing, 421) unless params[:retailer_ids].present?
            store_type_ids = RetailerStoreType.distinct.where("retailer_id in (#{params[:retailer_ids]})").pluck(:store_type_id).join(',')
            retailer_group_ids = Retailer.distinct.where("id in (#{params[:retailer_ids]})").where.not(retailer_group_id: nil).pluck(:retailer_group_id).join(',')
            chefs = Chef.distinct.joins(:recipes).where(recipes: {is_published: true}).limit(params[:limit]).offset(params[:offset])
            chefs = chefs.where.not("'{#{params[:retailer_ids]}}'::INT[] && recipes.exclude_retailer_ids") unless params[:retailer_ids].split(',').length > 1
            chefs = chefs.where("'{#{params[:retailer_ids]}}'::INT[] && recipes.retailer_ids OR '{#{store_type_ids}}'::INT[] && recipes.store_type_ids OR '{#{retailer_group_ids}}'::INT[] && recipes.retailer_group_ids")
            chefs = chefs.order("chefs.priority")
            chefs = chefs.where(id: params[:id]) if params[:id]

            present chefs, with: API::V2::Chefs::Entities::IndexEntity, web: request.headers['Referer']
          end
        end
      end
    end
  end
end

