# frozen_string_literal: true

module API
  module V1
    module Categories
      class ShopperCategories < Grape::API
        helpers API::V1::Concerns::SharedParams
        version 'v1', using: :path
        format :json
      
        resource :categories do
          desc "List of all product's categories.", entity: API::V1::Categories::Entities::IndexForRetailerEntity
          params do
            requires :limit, type: Integer, desc: 'Limit of categories', documentation: { example: 20 }
            requires :offset, type: Integer, desc: 'Offset of categories', documentation: { example: 10 }
            requires :retailer_id, type: Integer, desc: 'Id of retailer', documentation: {example: 1}
            optional :parent_id, type: Integer, desc: 'Id of category parent', documentation: {example: 1}
          end
      
          get '/shopper/tree' do
            # result = ::CategoriesEndpointService.result(params)
            # if params[:parent_id]
            #   present result, with: API::V1::Categories::Entities::IndexSubcategoriesForShopperEntity,
            #     retailer_id: params[:retailer_id]
            # else
            #   present result, with: API::V1::Categories::Entities::IndexForShopperEntity,
            #     retailer_id: params[:retailer_id]
            # end
            retailer = Retailer.find_by(id: params[:retailer_id])
            if params[:parent_id].present?
              parent = retailer.rcategories.find(params[:parent_id])
              result = retailer.rcategories.where(parent_id: parent)
            else
              result = retailer.rcategories.where(parent_id: nil)
            end
            result = result.order(:priority).distinct
            @is_next = params[:limit].to_i + params[:offset].to_i < result.length
      
            result = result.drop(params[:offset].to_i).first(params[:limit].to_i)
      
            result = [Category.find_by(id: 1)] + result if params['parent_id'].to_i == 1
            # result = [Category.find_by(id: 1)] + result if !params['parent_id'].present? && retailer.shops.where(is_promotional: true).count > 0
      
            result = { :next => @is_next, categories: result }
            present result, with: API::V2::Categories::Entities::ShopperCategoriesEntity, retailer_id: retailer.id
          end
        end
      end      
    end
  end
end