# frozen_string_literal: true

module API
  module V2
    module Products
      class List < Grape::API
        version 'v2', using: :path
        format :json
        helpers Concerns::ProductHelper

        resource :products do
          desc 'List of the products'

          params do
            requires :retailer_id, desc: 'Retailer Id', documentation: { example: 16 }
            requires :limit, type: Integer, desc: 'Limit', documentation: { example: 10 }
            requires :offset, type: Integer, desc: 'Offset', documentation: { example: 0 }
            requires :delivery_time, type: Integer, desc: 'Delivery Time', documentation: { example: 1619522915476 }
            optional :category_id, desc: 'category_id', documentation: { example: 90 }
            optional :subcategory_id, desc: 'Subcategory Id', documentation: { example: 100 }
            optional :brand_id, desc: 'Brand Id', documentation: { example: 16 }
          end

          get '/list' do
            error!({ error_code: 404, error_message: 'Retailer Not Found' }, 404) unless retailer_id
            products_cached = Rails.cache.fetch([params, __method__], expires_in: (retailer_id.with_stock_level ? 1 : 50).minutes) do
              error!(CustomErrors.instance.params_missing, 421) unless params[:category_id].present? || params[:subcategory_id].present?

              Product.retailer_of_product = retailer_id.id
              id_or_slug = params[:category_id].present? && params[:category_id] || params[:subcategory_id].present? && params[:subcategory_id]

              products = Product.joins(:product_categories, :retailer_shops).where(shops: { promotion_only: false })
              products =
                if id_or_slug.to_i == 1 || id_or_slug.to_s =~ /promotion|offer/
                  products.joins("INNER JOIN shop_promotions ON shop_promotions.product_id = products.id AND shop_promotions.is_active = 't' AND shop_promotions.retailer_id = #{retailer_id.id} AND #{params[:delivery_time]} BETWEEN shop_promotions.start_time AND shop_promotions.end_time")
                else
                  params[:subcategory_id].present? ? attach_subcategory(products) : attach_category(products)
                end
              products = products.where(brand_id: brand_id) if params[:brand_id].present?
              products = products.select_info
              sql1 = products.to_sql

              products = Product.joins(:product_categories, :retailer_shop_promotions, :retailer_shops).where(shops: { is_promotional: true, promotion_only: true })
              unless id_or_slug.to_i == 1 || id_or_slug.to_s =~ /promotion|offer/
                products = params[:subcategory_id].present? ? attach_subcategory(products) : attach_category(products)
              end
              products = products.where(brand_id: brand_id) if params[:brand_id].present?
              products = products.where("#{params[:delivery_time]} BETWEEN shop_promotions.start_time AND shop_promotions.end_time")
              products = products.select_info
              # products = products.group("products.id")
              sql2 = products.to_sql
              products = Product.find_by_sql("(#{sql1}) UNION (#{sql2}) ORDER BY product_rank desc, id desc offset #{params[:offset]} limit #{params[:limit]}")
              ActiveRecord::Associations::Preloader.new.preload(products, [:brand, :categories, :subcategories])
              ActiveRecord::Associations::Preloader.new.preload(products, :retailer_shop_promotions, { where: ("#{params[:delivery_time]} BETWEEN shop_promotions.start_time AND shop_promotions.end_time"), order: [:end_time, :start_time] })
              products.to_a
            end
            # shop_ids = products_cached.map(&:shop_id)
            # available_quantity = Redis.current.mapped_hmget('shops', *shop_ids) unless shop_ids.blank?
            # present products_cached, with: API::V2::Products::Entities::ListEntity, available_quantity: available_quantity
            present products_cached, with: API::V2::Products::Entities::ListEntity, retailer_with_stock: retailer_id.with_stock_level
          end
        end
      end
    end
  end
end
