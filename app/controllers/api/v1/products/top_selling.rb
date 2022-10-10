# frozen_string_literal: true

module API
  module V1
    module Products
      class TopSelling < Grape::API
        version 'v1', using: :path
        format :json

        resource :products do
          desc 'List of all Top Selling Products.', entity: API::V1::Products::Entities::ShowTopSellingEntity
          params do
            requires :limit, type: Integer, desc: 'Limit of products', documentation: { example: 20 }
            requires :offset, type: Integer, desc: 'Offset of products', documentation: { example: 10 }
            requires :retailer_id, desc: 'Retailer ID', documentation: { example: 20 }
            optional :category_id, desc: 'Category ID', documentation: { example: 20 }
            optional :subcategory_id, desc: 'SubCategory ID', documentation: { example: 20 }
            optional :brand_id, desc: 'Brand ID', documentation: { example: 20 }
            optional :shopper_id, type: Integer, desc: 'Shopper ID', documentation: { example: 20 }
            optional :is_trending, type: Boolean, desc: 'Show trending products', documentation: { example: true }
          end
          get '/show/top_selling' do
            # settings = Setting.first
            # most_selling_days = settings.try(:product_most_selling_days) || 30
            # trending_days = settings.try(:product_trending_days) || 7
            products_cached = Rails.cache.fetch([params.except(:ip_address), __method__], expires_in: 50.minutes) do
              retailer = params[:retailer_id][/\p{L}/] ? Retailer.select(:id).find_by(slug: params[:retailer_id]) : Retailer.select(:id).find_by(id: params[:retailer_id])
              error!({ error_code: 404, error_message: 'Retailer Not Found' }, 404) unless retailer
              category_id = params[:category_id].to_i.positive? ? params[:category_id].to_i : params[:category_id]
              subcategory_id = params[:subcategory_id].to_i.positive? ? params[:subcategory_id].to_i : params[:subcategory_id]
              brand_id = params[:brand_id].to_i.positive? ? params[:brand_id].to_i : params[:brand_id]
              # days = params[:is_trending] ? trending_days : most_selling_days
              days = params[:is_trending] ? 7 : 30

              products = Product.joins(:shops, :product_categories).includes(:brand, :categories, :subcategories).distinct #.top_selling(days, retailer.id, params[:shopper_id])
              # products = products.where(categories: {id: Category.find(params[:category_id])}) if params[:category_id]
              products = products.where(product_categories: { category_id: Category.select(:id).find(category_id).subcategory_ids }) if params[:category_id] && !params[:subcategory_id].present? && category_id != 1
              products = products.where(product_categories: { category_id: Category.select(:id).find(subcategory_id) }) if params[:subcategory_id]
              products = products.where(brand_id: Brand.select(:id).find(brand_id)) if params[:brand_id]
              products = products.where(shops: { retailer_id: retailer.id }) if retailer
              if params[:category_id] && !params[:subcategory_id].present? && category_id == 1
                products = products.where(shops: { is_promotional: true })
                products = products.joins("JOIN shop_promotions ON shop_promotions.retailer_id = shops.retailer_id AND shop_promotions.product_id = shops.product_id AND shop_promotions.is_active = 't' AND #{(Time.now.utc.to_f * 1000).floor} BETWEEN shop_promotions.start_time AND shop_promotions.end_time")
              end
              # products = products.where(order_positions: {order_id: Order.where(shopper_id: params[:shopper_id])}).having('SUM(order_positions.amount) > 0') if params[:shopper_id]
              products = products.where(id: Shopper.select(:id).find(params[:shopper_id]).order_positions.where(orders: { retailer_id: retailer.id }).select(:product_id).uniq.pluck(:product_id)) if params[:shopper_id]
              # products = products.where("order_positions.order_id is null or order_positions.order_id in (?)", Order.where("date(orders.created_at) >= ? and retailer_id = ?", days.day.ago.to_date, retailer).ids) unless params[:shopper_id]
              # products = products.where("date(orders.created_at) >= ?", trending_days.day.ago.to_date) if params[:is_trending]
              products = products.select('products.*, shops.price_currency,shops.price_dollars,shops.price_cents,shops.is_available,shops.is_published,shops.is_promotional,shops.product_rank,shops.updated_at,shops.retailer_id')
              products = products.limit(params[:limit]).offset(params[:offset])
              products = products.order('shops.product_rank desc', 'products.id desc')
              ActiveRecord::Associations::Preloader.new.preload(products, :shop_promotions, { where: ("retailer_id = #{retailer.id} AND #{(Time.now.utc.to_f * 1000).floor} BETWEEN shop_promotions.start_time AND shop_promotions.end_time"), order: [:end_time, :start_time] })
              products.to_a
            end

            present products_cached, with: API::V1::Products::Entities::ShowTopSellingEntity
          end
        end
      end
    end
  end
end
