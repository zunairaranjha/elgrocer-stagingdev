# frozen_string_literal: true

module API
  module V2
    module Categories
      class CategoryProducts < Grape::API
        version 'v2', using: :path
        format :json

        resource :categories do
          desc "List of all products of parent category. Requires authentication.", entity: API::V1::Categories::Entities::IndexForRetailerEntity
          params do
            requires :limit, type: Integer, desc: 'Limit of categories', documentation: { example: 20 }
            requires :offset, type: Integer, desc: 'Offset of categories', documentation: { example: 10 }
            requires :retailer_id, desc: 'Id or slug of retailer', documentation: { example: 1 }
            requires :parent_id, desc: 'Id or slug of category parent', documentation: { example: "1 or beverages" }
          end
          get '/products' do
            #normalize slug
            products_cached = Rails.cache.fetch([params.except(:ip_address), __method__], expires_in: 50.minutes) do
              retailer = params[:retailer_id][/\p{L}/] ? Retailer.select(:id).find_by(slug: params[:retailer_id]) : Retailer.select(:id).find_by(id: params[:retailer_id])
              parent_id = params[:parent_id].to_i > 0 ? params[:parent_id].to_i : params[:parent_id]

              # retailer = Retailer.find(retailer_id)
              sub_categories = Category.select(:id).find_by(id: params[:parent_id]).subcategory_ids if params[:parent_id].to_i != 1
              # new_result = {}
              # if Setting.last.enable_es_search
              #   result = Shop.search_products('', params[:retailer_id], nil, sub_categories, params[:limit], params[:offset])
              #   if result.results.total > 25
              #     is_next = (params[:limit] + params[:offset] < result.results.total) ? true : false
              #     new_result = {next: is_next, products: result, only_retailer: true }
              #   end
              # end
              # if new_result.blank?
              # products = retailer.products.includes(:brand, :shops)
              products = Product.joins(:shops, :product_categories).includes(:brand, :categories, :subcategories).distinct
              products = products.where(shops: { retailer_id: retailer.id })
              products = products.where(product_categories: { category_id: sub_categories }) if params[:parent_id].to_i != 1
              if params[:parent_id].to_i == 1
                products = products.where("shops.is_promotional = 't'")
                products = products.joins("JOIN shop_promotions ON shop_promotions.retailer_id = shops.retailer_id AND shop_promotions.product_id = shops.product_id AND shop_promotions.is_active = 't' AND #{(Time.now.utc.to_f * 1000).floor} BETWEEN shop_promotions.start_time AND shop_promotions.end_time")
              end
              products = products.select('products.*, shops.price_currency,shops.price_dollars,shops.price_cents,shops.is_available,shops.is_published,shops.is_promotional,shops.product_rank,shops.updated_at,shops.retailer_id')
              products = products.limit(params[:limit].to_i + 1).offset(params[:offset].to_i)
              products = products.order('shops.product_rank desc, products.id desc')
              ActiveRecord::Associations::Preloader.new.preload(products, :shop_promotions, { where: ("retailer_id = #{retailer.id} AND #{(Time.now.utc.to_f * 1000).floor} BETWEEN shop_promotions.start_time AND shop_promotions.end_time"), order: [:end_time, :start_time] })
              products.to_a
            end

            is_next = products_cached.length > params[:limit].to_i
            products_cached = products_cached.to_a.first(params[:limit].to_i)
            new_result = { next: is_next, products: products_cached, only_retailer: false }
            # end

            present new_result, with: API::V2::Retailers::Entities::ShowProductWithPaginationEntity
          end
        end
      end
    end
  end
end
