module API
  module V1
    module Products
      class ShowDetail < Grape::API
        version 'v1', using: :path
        format :json

        resource :products do
          desc "Find product by id in base.", entity: API::V1::Products::Entities::ShowEntity
          params do
            requires :retailer_id, desc: 'Retailer id', documentation: { example: "16 or ryan-market" }
            requires :product_id, desc: 'Product id', documentation: { example: "6 or pears" }
          end
          get '/show/detail' do
            retailer = params[:retailer_id][/\p{L}/] ? Retailer.select(:id).find_by(slug: params[:retailer_id]) : Retailer.select(:id).find_by(id: params[:retailer_id])
            # product = params[:product_id].to_i > 0 ? Product.unscoped.find_by(id: params[:product_id]) : Product.unscoped.find(params[:product_id])

            product = Product.unscoped.includes(:brand, :subcategories, :categories)
            product = product.joins("left outer join shops on shops.product_id = products.id and shops.retailer_id = #{retailer.id}")
            product = product.select('products.*,shops.id shop_id,shops.price_currency,shops.price_dollars,shops.price_cents,shops.is_available,shops.is_published,shops.retailer_id')
            product = product.find(params[:product_id])
            ActiveRecord::Associations::Preloader.new.preload(product, :shop_promotions, { where: ("retailer_id = #{retailer.id} AND #{(Time.now.utc.to_f * 1000).floor} BETWEEN shop_promotions.start_time AND shop_promotions.end_time"), order: [:end_time, :start_time] })

            if product.present?
              present product, with: API::V1::Products::Entities::ShowEntity, retailer: retailer
            else
              error!({ error_code: 403, error_message: "Product does not exist" }, 403)
            end
          end
        end
      end
    end
  end
end