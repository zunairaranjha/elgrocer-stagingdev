# frozen_string_literal: true

module API
  module V2
    module Products
      class PreviouslyPurchased < Grape::API
        version 'v2', using: :path
        format :json

        resource :products do
          desc 'Previously Purchased Products'

          params do
            requires :retailer_id, desc: 'Retailer Id', documentation: { example: 16 }
            requires :limit, type: Integer, desc: 'Limit', documentation: { example: 10 }
            requires :offset, type: Integer, desc: 'Offset', documentation: { example: 0 }
            requires :delivery_time, type: Integer, desc: 'Delivery Time', documentation: { example: 1619522915476 }
            requires :shopper_id, type: Integer, desc: 'Shopper Id', documentation: { example: 35099 }
          end

          get '/previously_purchased' do
            retailer = params[:retailer_id][/\p{L}/] ? Retailer.select(:id, :with_stock_level).find_by_slug(params[:retailer_id]) : Retailer.select(:id, :with_stock_level).find_by_id(params[:retailer_id])
            error!({ error_code: 404, error_message: 'Retailer Not Found' }, 404) unless retailer
            products_cached = Rails.cache.fetch([params.except(:ip_address), __method__], expires_in: (retailer.with_stock_level ? 1 : 50).minutes) do

              Product.retailer_of_product = retailer.id
              product_ids = Shopper.select(:id).find(params[:shopper_id]).order_positions.where(orders: { retailer_id: retailer.id }).select(:product_id).uniq.pluck(:product_id)
              products = Product.joins(:retailer_shops).where(shops: { promotion_only: false })
              products = products.where(id: product_ids)
              products = products.select_info
              sql1 = products.to_sql
              products = Product.joins(:retailer_shop_promotions, :retailer_shops).where(shops: { is_promotional: true, promotion_only: true })
              products = products.where(id: product_ids)
              products = products.where("#{params[:delivery_time]} BETWEEN shop_promotions.start_time AND shop_promotions.end_time")
              products = products.select_info
              sql2 = products.to_sql
              products = Product.find_by_sql("(#{sql1}) UNION (#{sql2}) ORDER BY product_rank desc, id desc offset #{params[:offset]} limit #{params[:limit]}")
              ActiveRecord::Associations::Preloader.new.preload(products, %i[brand categories subcategories])
              ActiveRecord::Associations::Preloader.new.preload(products, :retailer_shop_promotions, { where: ("#{params[:delivery_time]} BETWEEN shop_promotions.start_time AND shop_promotions.end_time"), order: %i[end_time start_time] })
              products.to_a
            end
            # shop_ids = products_cached.map(&:shop_id)
            # available_quantity = Redis.current.mapped_hmget('shops', *shop_ids) unless shop_ids.blank?
            # present products_cached, with: API::V2::Products::Entities::ListEntity, available_quantity: available_quantity
            present products_cached, with: API::V2::Products::Entities::ListEntity, retailer_with_stock: retailer.with_stock_level
          end
        end
      end
    end
  end
end
