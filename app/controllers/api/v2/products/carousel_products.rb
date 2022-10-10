# frozen_string_literal: true

module API
  module V2
    module Products
      class CarouselProducts < Grape::API
        version 'v2', using: :path
        format :json

        resource :products do
          desc 'To get the Carousel Products'

          params do
            requires :retailer_id, type: Integer, desc: 'Retailer Id', documentation: { example: 16 }
            requires :delivery_time, type: Float, desc: 'Delivery Time In millis', documentation: { example: 123456789000 }
          end

          get '/carousel_products' do
            retailer = Retailer.select(:id, :with_stock_level).find_by_id(params[:retailer_id])
            error!({ error_code: 404, error_message: 'Retailer Not Found' }, 404) unless retailer
            products_cached = Rails.cache.fetch([params, __method__], expires_in: (retailer.with_stock_level ? 1 : 50).minutes) do
              product_ids = CarouselProduct.where('? between start_date and end_date', Time.now.utc).pluck(:product_ids)
              products = []
              if product_ids.present?
                Product.retailer_of_product = retailer.id
                product_ids = product_ids.to_s.scan(/\d+/)
                products = retailer.products.where(shops: { promotion_only: false }, id: product_ids)
                products = products.select_info
                sql1 = products.order('RANDOM()').to_sql
                products = Product.joins(:retailer_shop_promotions, :retailer_shops).where(shops: { is_promotional: true, promotion_only: true }, id: product_ids)
                                  .where("#{params[:delivery_time]} BETWEEN shop_promotions.start_time AND shop_promotions.end_time")
                products = products.select_info
                sql2 = products.order('RANDOM()').to_sql
                products = Product.find_by_sql("(#{sql1}) UNION (#{sql2})")
                ActiveRecord::Associations::Preloader.new.preload(products, %i[brand categories subcategories])
                ActiveRecord::Associations::Preloader.new.preload(products, :retailer_shop_promotions, {
                                                                    where: ("#{params[:delivery_time]} BETWEEN shop_promotions.start_time AND shop_promotions.end_time"), order: %i[end_time start_time] })
              end
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
