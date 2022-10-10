module API
  module V1
    module Campaigns
      class Products < Grape::API
        version 'v1', using: :path
        format :json

        resource :campaigns do
          desc 'Products of a campaign'

          params do
            requires :retailer_id, type: Integer, desc: 'Id of the Retailer', documentation: { example: 16 }
            requires :campaign_id, type: Integer, desc: 'Campaign Id', documentation: { example: 1 }
            requires :limit, type: Integer, desc: 'Limit', documentation: { example: 10 }
            requires :offset, type: Integer, desc: 'Offset', documentation: { example: 0 }
          end

          get '/products' do
            retailer = Retailer.select(:id).find_by(id: params[:retailer_id])
            error!(CustomErrors.instance.retailer_not_found, 421) unless retailer
            products = Product.joins(:shops).includes(:brand, :categories, :subcategories)
            products = products.joins("INNER JOIN campaigns ON products.id = ANY(campaigns.product_ids) AND campaigns.id = #{params[:campaign_id]}")
            products = products.where(shops: { retailer_id: retailer.id })
            products = products.select('products.*, shops.price_currency,shops.price_dollars,shops.price_cents,shops.is_available,shops.is_published,shops.is_promotional,shops.product_rank,shops.updated_at,shops.retailer_id')
            products = products.limit(params[:limit].to_i).offset(params[:offset])
            ActiveRecord::Associations::Preloader.new.preload(products, :shop_promotions, { where: ("retailer_id = #{retailer.id} AND #{(Time.now.utc.to_f * 1000).floor} BETWEEN shop_promotions.start_time AND shop_promotions.end_time"), order: [:end_time, :start_time] })

            API::V1::Products::Entities::ProductsEntity.represent products, root: false
          end
        end
      end
    end
  end
end

