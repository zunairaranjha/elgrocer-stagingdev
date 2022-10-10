module API
  module V1
    module Products
      class Catalog < Grape::API
        version 'v1', using: :path
        format :json
      
        resource :products do
          desc "List of all products in base or only in my shop. Requires authentication.", entity: API::V1::Products::Entities::ShowEntity
          params do
            requires :limit, type: Integer, desc: 'Limit of products', documentation: { example: 20 }
            requires :offset, type: Integer, desc: 'Offset of products', documentation: { example: 10 }
            optional :category_id, type: Integer, desc: 'Category ID', documentation: { example: 20 }
            optional :subcategory_id, type: Integer, desc: 'SubCategory ID', documentation: { example: 20 }
            optional :brand_id, type: Integer, desc: 'Brand ID', documentation: { example: 20 }
          end
          get '/master/catalog' do
            products = Product.order(id: :desc).includes(:categories, :subcategories, :brand).limit(params['limit']).offset(params['offset'])
            products = products.where(brand_id: params['brand_id']) unless params[:brand_id].nil?
            # products = products.joins(:categories) if params.has_key?(:category_id) || params.has_key?(:subcategory_id)
            products = products.where(categories: {id: params[:category_id]}) unless params[:category_id].nil?
            products = products.where(product_categories: {category_id: params[:subcategory_id]}) unless params[:subcategory_id].nil?
            present products, with: API::V1::Products::Entities::ShowEntity
          end
        end
      end
    end
  end
end