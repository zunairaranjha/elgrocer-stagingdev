# frozen_string_literal: true

module API
  module V1
    module Products
      class Promotional < Grape::API
        version 'v1', using: :path
        format :json

        resource :products do
          desc "Promotional Products.", entity: API::V1::Products::Entities::ShowEntity
          params do
            requires :retailer_id, type: Integer, desc: 'Retailer ID', documentation: { example: 20 }
            requires :limit, type: Integer, desc: 'Limit of products', documentation: { example: 20 }
            requires :offset, type: Integer, desc: 'Offset of products', documentation: { example: 10 }
            optional :category_id, type: Integer, desc: 'Category Id', documentation: { example: 21 }
            optional :subcategory_id, type: Integer, desc: 'Subcategory Id', documentation: { example: 23 }
            optional :brand_id, type: Integer, desc: 'Brand Id', documentation: { example: 12 }
          end
          get '/show/promotional' do
            retailer = Retailer.select(:id).find_by(id: params[:retailer_id])
            products = Product.joins(:shops, :product_categories).includes(:subcategories, :categories, :brand, :shops).where(is_promotional: true, shops: { retailer_id: retailer.id })
            products = products.where(product_categories: { category_id: Category.select(:id).find(params[:category_id]).subcategory_ids }) if params[:category_id] && !params[:subcategory_id].present?
            products = products.where(product_categories: { category_id: params[:subcategory_id] }) if params[:subcategory_id]
            products = products.where(brand_id: params[:brand_id]) if params[:brand_id]
            products = products.limit(params[:limit]).offset(params[:offset]) #if products.any?
            present products, with: API::V1::Products::Entities::ShowEntity, retailer: retailer
          end
        end
      end
    end
  end
end