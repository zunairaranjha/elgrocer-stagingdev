# frozen_string_literal: true

module API
  module V2
    module Categories
      class CategoryShopperBrands < Grape::API
        version 'v2', using: :path
        format :json
      
        resource :categories do
          desc "List of all category's brands. Requires authentication.", entity: API::V2::Categories::Entities::CategoryBrandsEntity
          params do
            requires :category_id, desc: 'Id of category parent', documentation: {example: 1}
            requires :retailer_id, desc: 'Id or slug of Retailer', documentation: {example: 1}
            optional :limit, type: Integer, desc: 'Limit of Brands', documentation: { example: 20 }
            optional :offset, type: Integer, desc: 'Offset of Brands', documentation: { example: 10 }
          end
          get '/shopper/brands' do
            retailer_id = Retailer.find(params[:retailer_id]).id
            category_id = Category.find(params[:category_id]).id
      
            brand_sql = "SELECT DISTINCT (b.id) FROM categories AS c INNER JOIN categories AS sc ON c.id = sc.parent_id INNER JOIN product_categories AS pc ON pc.category_id = sc.id INNER JOIN products AS p ON p.id = pc.product_id INNER JOIN brands AS b ON b.id = p.brand_id INNER JOIN shops AS s ON p.id = s.product_id WHERE s.retailer_id = #{retailer_id} AND sc.id = #{category_id}"
      
            brands = Brand.where("id in (#{brand_sql})").order(:priority,:id)
      
            is_next = false
            if params[:limit].present? && params[:offset].present?
              @is_next = params[:limit].to_i + params[:offset].to_i < brands.count
              brands = brands.limit(params[:limit]).offset(params[:offset])
            end
      
            result = { :next => @is_next, :brands => brands }
            present result, with: API::V2::Categories::Entities::CategoryBrandsEntity
          end
        end
      end      
    end
  end
end