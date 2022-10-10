# frozen_string_literal: true

module API
  module V1
    module Products
      class Featured < Grape::API
        version 'v1', using: :path
        format :json

        resource :products do
          desc "Feaured Products.", entity: API::V1::Products::Entities::ShowEntity
          params do
            requires :limit, type: Integer, desc: 'Limit of products', documentation: { example: 20 }
            requires :offset, type: Integer, desc: 'Offset of products', documentation: { example: 10 }
            requires :retailer_id, desc: 'Retailer ID', documentation: { example: 20 }
          end
          get '/show/featured' do
            retailer = params[:retailer_id][/\p{L}/] ? Retailer.select(:id).find_by(slug: params[:retailer_id]) : Retailer.select(:id).find_by(id: params[:retailer_id])
            product_ids = BrandSearchKeyword.where('? between date(start_date) and date(end_date)', Time.now.to_date).pluck(:product_ids)
            if product_ids.present?
              product_ids = product_ids.to_s.scan(/\d+/)
              # products = Product.where(id: product_ids).joins(:shops).where(shops: {retailer_id: retailer.id}).order('shops.product_rank desc, products.id').limit(params[:limit]).offset(params[:offset])
              products = Product.where(shops: { retailer_id: retailer.id }).where(id: product_ids).includes(:subcategories, :categories, :brand, :shops).order('shops.product_rank desc, shops.product_id desc').limit(params[:limit]).offset(params[:offset])
              # products = retailer.shops.joins(:product).where(product_id: product_ids).select('products.*')
            end

            # products_cached = Rails.cache.fetch([params.merge(shops_updated_at: "#{products.maximum('shops.updated_at')}"),__method__], expires_in: 10.hours) do
            #   products.to_a
            # end
            present products, with: API::V1::Products::Entities::ShowEntity, retailer: retailer
          end
        end
      end
    end
  end
end