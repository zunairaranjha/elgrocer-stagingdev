module API
  module V1
    module Products
      class BrandProduct < Grape::API
        version 'v1', using: :path
        format :json

        resource :products do
          desc 'List of the products'

          params do
            requires :retailer_id, desc: 'Retailer Id', documentation: { example: 16 }
            requires :limit, type: Integer, desc: 'Limit', documentation: { example: 10 }
            requires :offset, type: Integer, desc: 'Offset', documentation: { example: 0 }
            requires :delivery_time, type: Integer, desc: 'Delivery Time', documentation: { example: 1619522915476 }
            optional :category_id, desc: 'category_id', documentation: { example: 90 }
            optional :subcategory_id, desc: 'Subcategory Id', documentation: { example: 100 }
            requires :brand_id, desc: 'Brand Id', documentation: { example: 16 }
          end

          get '/show/brand_products' do
            retailer = params[:retailer_id][/\p{L}/] ? Retailer.select(:id, :with_stock_level).find_by_slug(params[:retailer_id]) : Retailer.select(:id, :with_stock_level).find_by_id(params[:retailer_id])
            error!({ error_code: 404, error_message: 'Retailer Not Found' }, 404) unless retailer
            products_cached = Rails.cache.fetch([params.except(:ip_address), __method__], expires_in: (retailer.with_stock_level ? 1 : 50).minutes) do

              Product.retailer_of_product = retailer.id

              products = Product.joins(:retailer_shops).where(brand_id: attach_brand_id, shops: { promotion_only: false })
              if params[:category_id].present? || params[:subcategory_id].present?
                products = products.joins(:product_categories)
                products = params[:subcategory_id].present? ? attach_subcategory(products) : attach_category(products)
              end
              products = products.select_info
              sql1 = products.to_sql

              products = Product.joins(:retailer_shop_promotions, :retailer_shops).where(brand_id: attach_brand_id, shops: { is_promotional: true, promotion_only: true })
              if params[:category_id].present? || params[:subcategory_id].present?
                products = products.joins(:product_categories)
                products = params[:subcategory_id].present? ? attach_subcategory(products) : attach_category(products)
              end
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

        helpers do
          def subcategory_id
            @subcategory_id ||= params[:subcategory_id][/\p{L}/] ? Category.select(:id).find_by_slug(params[:subcategory_id]) : Category.select(:id).find_by_id(params[:subcategory_id])
          end

          def subcategories_ids
            @child_ids ||= Category.joins(:parent).where(params[:category_id][/\p{L}/] ? "parents_categories.slug = '#{params[:category_id]}'" : "parents_categories.id = #{params[:category_id]}").select(:id)
          end

          def attach_subcategory(products)
            products.where(product_categories: { category_id: subcategory_id })
          end

          def attach_category(products)
            products.where(product_categories: { category_id: subcategories_ids })
          end

          def attach_brand_id
            params[:brand_id][/\p{L}/] ? Brand.select(:id).find_by_slug(params[:brand_id]) : params[:brand_id]
          end
        end
      end
    end
  end
end

