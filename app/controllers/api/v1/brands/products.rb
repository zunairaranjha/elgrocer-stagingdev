module API
  module V1
    module Brands
      class Products < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :brands do
          desc "List of all products in base per brand. Requires authentication.", entity: API::V1::Brands::Entities::ShowProductPerBrandEntity
          # desc "List of all products in base per brand. Requires authentication.", entity: API::V1::Products::Entities::IndexForShopperEntity
          params do
            requires :limit, type: Integer, desc: 'Limit of products', documentation: { example: 20 }
            requires :offset, type: Integer, desc: 'Offset of products', documentation: { example: 10 }
            requires :brand_id, type: Integer, desc: 'Brand id', documentation: { example: 10 }
            optional :sub_category_id, type: Integer, desc: 'Optional input for subcategory', documentation: { example: 10 }
          end
          get '/products' do

            if current_employee
              retailer = current_employee.retailer || Retailer.find_by(id: params[:retailer_id])
            else
              retailer = current_retailer
            end

            error!(CustomErrors.instance.not_allowed, 421) unless retailer

            brand_id = params[:brand_id].to_i > 0 ? params[:brand_id] : nil

            products = Product.unscoped.includes(:brand, :categories, :subcategories).where(brand_id: brand_id)
            products = products.where(product_categories: { category_id: params[:sub_category_id] }) if params[:sub_category_id]
            products = products.joins("left outer join shops on shops.product_id = products.id and shops.retailer_id = #{retailer.id}").select('products.*,shops.id shop_id,shops.price_currency,shops.price_dollars,shops.price_cents,shops.is_available,shops.is_published,shops.retailer_id') if retailer
            products = products.order(created_at: :desc).limit(params['limit']).offset(params['offset'])
            # products = products.joins(:shops).preload(:shops).where(shops: {retailer_id: current_retailer.id}) if current_retailer

            present products, with: API::V1::Products::Entities::ShowEntity, retailer: retailer
          end
        end
      end
    end
  end
end