module API
  module V2
    module Retailers
      class ShowProducts < Grape::API
        version 'v2', using: :path
        format :json

        resource :retailers do
          desc 'Returns products of a retailer.', entity: API::V1::Products::Entities::ElasticSearchEntity
          params do
            requires :retailer_id, desc: 'Retailer ID / Slug'
            optional :brand_id, desc: 'Brand ID / Slug', documentation: { example: '1 or lays' }
            optional :category_id, desc: 'Category ID / Slug', documentation: { example: '1 or beverages' }
            optional :limit, type: Integer, desc: 'limit of products'
            optional :offset, type: Integer, desc: 'offset'
            # optional :page, type: Integer, desc: 'page'
          end

          get '/products' do
            ##### Handle forgery
            params[:limit] = params[:limit] || 100
            params[:offset] = params[:offset] || 0
            # params[:limit] = params[:limit] > 100 ? 100 : params[:limit]
            # params[:offset] = params[:offset] > 500 ? 500 : params[:offset]
            ### Handle forgry
            # new_result = {}
            # if Setting.last.enable_es_search
            #   result = Shop.search_products('', params[:retailer_id], params[:brand_id], [params[:category_id]], params[:limit] || 100, params[:offset])
            #   if result.results.total > 25
            #     is_next = (params[:limit].present?  ? ((params[:limit] + params[:offset] < result.results.total) ? true : false) : (result.results.count !=0) ? true : false)
            #     new_result = {next: is_next, products: result, only_retailer: true }
            #   end
            # end
            # if new_result.blank?
            # result = ::Retailers::ShowProducts.run(params)
            # is_next = result.result.nil? ? false : result.result.first
            # products = result.result.nil? ? [] : result.result.second

            products_cached = Rails.cache.fetch([params.except(:ip_address), __method__], expires_in: 50.minutes) do
              retailer = params[:retailer_id][/\p{L}/] ? Retailer.select(:id).find_by(slug: params[:retailer_id]) : Retailer.select(:id).find_by(id: params[:retailer_id])
              error!({ error_code: 404, error_message: 'Retailer Not Found' }, 404) unless retailer
              # subcategory_id = params[:subcategory_id].to_i > 0 ? params[:subcategory_id].to_i : params[:subcategory_id]

              # retailer = Retailer.find(retailer_id)

              # products = retailer.products.includes(:categories, :brand)
              products = Product.joins(:shops).includes(:brand, :categories, :subcategories).distinct
              if params[:category_id].present?
                category = params[:category_id][/\p{L}/] ? Category.select(:id).find_by(slug: params[:category_id]) : Category.select(:id).find_by(id: params[:category_id])
                error!(CustomErrors.instance.category_not_found, 421) unless category
                products = products.joins(:product_categories)
                if category.id == 1
                  products = products.where(shops: { is_promotional: true })
                  products = products.joins("JOIN shop_promotions ON shop_promotions.retailer_id = shops.retailer_id AND shop_promotions.product_id = shops.product_id AND shop_promotions.is_active = 't' AND #{(Time.now.utc.to_f * 1000).floor} BETWEEN shop_promotions.start_time AND shop_promotions.end_time")
                else
                  products = products.where(product_categories: { category_id: category.id })
                end
              end
              if params[:brand_id].present?
                brand = params[:brand_id][/\p{L}/] ? Brand.select(:id).find_by(slug: params[:brand_id]) : Brand.select(:id).find_by(id: params[:brand_id])
                error!(CustomErrors.instance.brand_not_found, 421) unless brand
                products = products.where(brand_id: brand.id)
              end
              products = products.where(shops: { retailer_id: retailer.id }) if retailer
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
            present new_result, with: API::V2::Retailers::Entities::ShowProductWithPaginationEntity, web: request.headers['Referer']
          end
        end
      end
    end
  end
end