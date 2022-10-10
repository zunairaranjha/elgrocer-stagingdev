module API
  module V1
    module Categories
      class CategoryBrands < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :categories do
          desc "List of all category's brands. Requires authentication.", entity: API::V1::Categories::Entities::CategoryBrandsEntity
          params do
            requires :category_id, type: Integer, desc: 'Id of category parent', documentation: { example: 1 }
            optional :retailer_id, type: Integer, desc: 'Id of brands', documentation: { example: 1 }
          end
          get '/brands' do
            retailer_id = params[:retailer_id]
            category_id = params[:category_id]
      
            brand_sql = "SELECT DISTINCT (b.id) FROM categories AS c INNER JOIN categories AS sc ON c.id = sc.parent_id INNER JOIN product_categories AS pc ON pc.category_id = sc.id INNER JOIN products AS p ON p.id = pc.product_id INNER JOIN brands AS b ON b.id = p.brand_id INNER JOIN shops AS s ON p.id = s.product_id WHERE s.retailer_id = #{retailer_id} AND sc.id = #{category_id}" if retailer_id
      
            brands = Category.includes(:brands).find(params[:category_id]).brands
            result = {:brands => brands}
            present result, with: API::V1::Categories::Entities::CategoryBrandsEntity
          end
        end
      end      
    end
  end
end