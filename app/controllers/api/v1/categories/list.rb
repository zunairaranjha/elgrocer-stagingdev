# frozen_string_literal: true

module API
  module V1
    module Categories
      class List < Grape::API
        version 'v1', using: :path
        format :json

        resource :categories do
          desc 'This will list categories and subcategories of a retailer'

          params do
            requires :retailer_id, desc: 'Id/slug of the retailer', documentation: { example: '16/ryan-market-test' }
            requires :delivery_time, type: Float, desc: 'delivery time in millis', documentation: { example: 1234567890 }
            optional :parent_id, desc: 'Id/Slug of category parent', documentation: { example: "1 or beverages" }
          end

          get '/list' do
            error!(CustomErrors.instance.retailer_not_found, 421) unless retailer
            result = []
            params[:delivery_time] = (Time.now.utc.to_f * 1000).floor unless params[:delivery_time].to_i.positive?
            if params[:parent_id].present?
              promotion_parent = (params[:parent_id].to_i == 1 or params[:parent_id].to_s =~ /promotion|offer/)
              result = Rails.cache.fetch("list/#{retailer.id}/category/#{params[:parent_id]}/subcategories/limit/1000/offset/0", expires_in: 15.minutes) do
                parent = Category.categories_list(retailer.id, params[:delivery_time], params[:parent_id]).first
                result = Category.subcategories_list(retailer.id, parent.id, params[:delivery_time]) if parent
                result = promotion_category(result, promotion_parent: promotion_parent)
                result.to_a
              end
            else
              result = Rails.cache.fetch("list/#{retailer.id}/categories/limit/1000/offset/0", expires_in: 15.minutes) do
                result = Category.categories_list(retailer.id, params[:delivery_time])
                result = promotion_category(result)
                result.to_a
              end
            end

            error!(CustomErrors.instance.category_not_found, 421) if result.blank? and !promotion_parent
            present result, with: API::V1::Categories::Entities::ListEntity, retailer_id: retailer.id, web: request.headers['Referer']
          end
        end

        helpers do
          def promotion_category(result, promotion_parent: nil)
            if result.select { |cat| cat.id == 1 }.length < 1 and (promotion_parent or (!params[:parent_id].present? and retailer.shop_promotions.where("? between start_time and end_time", params[:delivery_time]).count > 0))
              result = Category.joins(:retailer_categories).where(id: 1, retailer_categories: { retailer_id: retailer.id }) + result
            end
            result
          end

          def retailer
            @retailer ||= params[:retailer_id][/\p{L}/] ? Retailer.select(:id).find_by(slug: params[:retailer_id]) : Retailer.select(:id).find_by(id: params[:retailer_id])
          end
        end
      end
    end
  end
end

