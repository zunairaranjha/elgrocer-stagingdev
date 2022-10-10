module API
  module V1
    module Screens
      class ScreenProducts < Grape::API
        # include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :screens do
          desc "List of all the custom screens for a retailer", entity: API::V1::Screens::Entities::IndexEntity
          params do
            requires :limit, type: Integer, desc: 'Limit of products', documentation: { example: 20 }
            requires :offset, type: Integer, desc: 'Offset of products', documentation: { example: 10 }
            requires :screen_id, type: Integer, desc: 'Screen Id', documentation: { example: 10 }
            requires :retailer_id, type: Integer, desc: "Retailer id", documentation: { example: 10 }
          end

          get '/screen_products' do
            retailer = Retailer.select(:id).find_by(id: params[:retailer_id])
            if retailer
              products = Product.joins(:screen_products, :shops).includes(:brand, :categories, :subcategories)
              products = products.where(screen_products: { screen_id: params[:screen_id] })
              products = products.where(shops: { retailer_id: retailer.id })
              products = products.select('products.*, shops.price_currency,shops.price_dollars,shops.price_cents,shops.is_available,shops.is_published,shops.is_promotional,shops.product_rank,shops.updated_at,shops.retailer_id')
              products = products.limit(params[:limit].to_i + 1).offset(params[:offset])
              products = products.order("screen_products.priority")

              is_next = products.length > params[:limit].to_i
              products = products.to_a.first(params[:limit].to_i)
              ActiveRecord::Associations::Preloader.new.preload(products, :shop_promotions, { where: ("retailer_id = #{retailer.id} AND #{(Time.now.utc.to_f * 1000).floor} BETWEEN shop_promotions.start_time AND shop_promotions.end_time"), order: [:end_time, :start_time] })
              new_result = { next: is_next, products: products }

              present new_result, with: API::V1::Products::Entities::ProductPaginationEntity
            else
              error!({ error_code: 401, error_message: "Retailer not found" }, 401)
            end
          end
        end
      end
    end
  end
end