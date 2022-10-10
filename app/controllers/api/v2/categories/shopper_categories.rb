# frozen_string_literal: true

module API
  module V2
    module Categories
      class ShopperCategories < Grape::API
        helpers API::V1::Concerns::SharedParams
        version 'v2', using: :path
        format :json

        resource :categories do
          desc "List of all product's categories.", entity: API::V2::Categories::Entities::IndexForRetailerEntity
          params do
            optional :limit, type: Integer, desc: 'Limit of categories', documentation: { example: 20 }
            optional :offset, type: Integer, desc: 'Offset of categories', documentation: { example: 10 }
            requires :retailer_id, desc: 'Id/Slug of retailer', documentation: { example: "1 or ryan-market" }
            optional :parent_id, desc: 'Id/Slug of category parent', documentation: { example: "1 or beverages" }
          end

          get '/shopper/tree1' do
            retailer = params[:retailer_id][/\p{L}/] ? Retailer.select(:id).find_by(slug: params[:retailer_id]) : Retailer.select(:id).find_by(id: params[:retailer_id])
            result = ::CategoriesEndpointService.result(params)
            if params[:parent_id]
              present result, with: API::V2::Categories::Entities::IndexSubcategoriesForShopperEntity,
                      retailer_id: retailer.id
            else
              present result, with: API::V2::Categories::Entities::IndexForShopperEntity,
                      retailer_id: retailer.id
            end
          end

          get '/shopper/tree' do
            retailer = params[:retailer_id][/\p{L}/] ? Retailer.select(:id).find_by(slug: params[:retailer_id]) : Retailer.select(:id).find_by(id: params[:retailer_id])
            if retailer
              if params[:limit].to_i < 1000
                params[:limit] = 1000
                params[:offset] = 0
              else
                params[:limit] = params[:limit]
              end
              result = []
              is_next = false
              if params[:parent_id].present?
                # parent = Category.joins(:retailer_categories).where("retailer_categories.retailer_id = #{retailer.id}").find(params[:parent_id])
                # result = retailer.subcategories.joins(:retailer_categories).where("retailer_categories.retailer_id = #{retailer.id}").where(parent: parent)
                promotion_parent = (params[:parent_id].to_i == 1 or params[:parent_id].to_s.include?('promotion'))
                result = Rails.cache.fetch("#{retailer.id}/category/#{params[:parent_id]}/subcategories/limit/#{params[:limit]}/offset/#{params[:offset]}", expires_in: 15.minutes) do
                  parent = Category.get_categories(retailer.id)
                  if params[:parent_id][/\p{L}/]
                    parent = parent.find_by(slug: params[:parent_id])
                  else
                    parent = parent.find_by(id: params[:parent_id])
                  end
                  if parent
                    result = Category.get_subcategories(retailer.id, parent.id).order(:priority).distinct
                    result = result.limit(params[:limit].to_i + 1).offset(params[:offset].to_i) if params[:limit] and params[:offset]
                  end
                  # add promotion category
                  if result.select { |cat| cat.id == 1 }.length < 1 and (promotion_parent or (!params[:parent_id].present? and retailer.shops.where(is_promotional: true).count > 0))
                    result = Category.joins(:retailer_categories).where(id: 1, retailer_categories: { retailer_id: retailer.id }) + result
                  end
                  result.to_a
                end
                # result = retailer.rcategories.where(parent_id: parent) if parent
              else
                result = Rails.cache.fetch("#{retailer.id}/categories/limit/#{params[:limit]}/offset/#{params[:offset]}", expires_in: 15.minutes) do
                  result = Category.get_categories(retailer.id).order(:priority).distinct
                  result = result.limit(params[:limit].to_i + 1).offset(params[:offset].to_i) if params[:limit] and params[:offset]
                  # add promotion category
                  if result.select { |cat| cat.id == 1 }.length < 1 and (promotion_parent or (!params[:parent_id].present? and retailer.shops.where(is_promotional: true).count > 0))
                    result = Category.joins(:retailer_categories).where(id: 1, retailer_categories: { retailer_id: retailer.id }) + result
                  end
                  result.to_a
                end
                # result = retailer.rcategories.where(parent_id: nil)
                # result = retailer.categories.joins(:retailer_categories).where("retailer_categories.retailer_id = #{retailer.id}")
              end

              # result = result.where('products.brand_id is not null')
              if result.blank? and !promotion_parent
                error!({ error_code: 421, error_message: "Category not found" }, 421)
              else
                if params[:limit]
                  is_next = params[:limit].to_i < result.length
                  result = result.to_a.first(params[:limit].to_i)
                end

                # result = [Category.find_by(id: 1)] + result if !params['parent_id'].present? && retailer.shops.where(is_promotional: true).count > 0

                result = { :next => is_next, categories: result }
                present result, with: API::V2::Categories::Entities::ShopperCategoriesEntity, retailer_id: retailer.id, web: request.headers['Referer']
              end
            else
              error!({ error_code: 401, error_message: "Retailer not found" }, 401)
            end
          end
        end
      end
    end
  end
end