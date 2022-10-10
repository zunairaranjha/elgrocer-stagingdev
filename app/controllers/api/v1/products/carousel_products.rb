module API
  module V1
    module Products
      class CarouselProducts < Grape::API
        version 'v1', using: :path
        format :json

        resource :products do
          desc 'Carousel Products.', entity: API::V1::Products::Entities::ShowEntity
          params do
            optional :limit, type: Integer, desc: 'Limit of products', documentation: { example: 20 }
            optional :offset, type: Integer, desc: 'Offset of products', documentation: { example: 10 }
            requires :retailer_id, desc: 'Retailer ID', documentation: { example: 20 }
          end
          get '/show/carousel_products' do
            retailer = params[:retailer_id][/\p{L}/] ? Retailer.select(:id).find_by(slug: params[:retailer_id]) : Retailer.select(:id).find_by(id: params[:retailer_id])
            error!({ error_code: 404, error_message: 'Retailer Not Found' }, 404) unless retailer
            products_cached = Rails.cache.fetch([params, __method__], expires_in: 50.minutes) do
              product_ids = CarouselProduct.where('? between start_date and end_date', Time.now.utc).pluck(:product_ids)
              products = []
              if product_ids.present?
                product_ids = product_ids.to_s.scan(/\d+/)
                products = Product.where(shops: { retailer_id: retailer.id }).where(id: product_ids).includes(:subcategories, :categories, :brand, :shops).order('RANDOM()').limit(params[:limit]).offset(params[:offset])
                ActiveRecord::Associations::Preloader.new.preload(products, :shop_promotions, { where: ("retailer_id = #{retailer.id} AND #{(Time.now.utc.to_f * 1000).floor} BETWEEN shop_promotions.start_time AND shop_promotions.end_time"), order: [:end_time, :start_time] })
                # products.to_a
              end
              products.to_a
            end
            present products_cached, with: API::V1::Products::Entities::ShowEntity, retailer: retailer
          end
        end
      end
    end
  end
end