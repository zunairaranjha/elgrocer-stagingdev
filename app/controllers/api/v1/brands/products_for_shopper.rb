
module API
  module V1
    module Brands
      class ProductsForShopper < Grape::API
        version 'v1', using: :path
        format :json
      
        resource :brands do
          desc "List of all products in base per brand. Requires authentication.", entity: API::V1::Brands::Entities::ShowProductPerBrandEntity
          params do
            optional :page, type: Integer, desc: 'Page of products collection', documentation: { example: 2 }
            requires :brand_id, type: Integer, desc: 'Brand id', documentation: { example: 10 }
            optional :subcategory_id, type: Integer, desc: 'Subcategory id', documentation: { example: 10 }
            optional :location_id, type: Integer, desc: 'Location id - show only products avaliable in shops in location. If location is empty or there is no retailer in location show all product', documentation: { example: 2 }
          end
      
          get '/shopper/products' do
            page = params[:page]
            retailers_in_location = Retailer.joins(:locations).where(locations: {id: params[:location_id] }).count > 0 if params[:location_id].present?
      
            if params[:location_id].present? && retailers_in_location
              retailers_ids = Retailer.joins(:locations, :retailer_opening_hours).where(is_active: true, is_opened: true, locations: { id: params[:location_id] }).where("retailer_opening_hours.open < #{Time.now.seconds_since_midnight} AND retailer_opening_hours.close > #{Time.now.seconds_since_midnight}").pluck(:id)
      
              products = Product.where('products.id IN (?)', Shop.where('shops.retailer_id IN (?)', retailers_ids).uniq.pluck(:product_id))
            else
              products = Product.where('products.id IN (SELECT DISTINCT(shops.product_id) FROM shops)')
            end
      
            if params[:subcategory_id]
              products = products.where(brand_id: params[:brand_id]).joins(:product_categories).where("product_categories.category_id = ?", params[:subcategory_id]).uniq.order(created_at: :desc)
            else
              products = products.where(brand_id: params[:brand_id]).order(created_at: :desc)
            end
            products = products.page(page) if page
            result = {products: products}
      
            present result, with: API::V1::Brands::Entities::ShowProductPerBrandEntity
            # query = {
            #         bool: {
            #           must: [
            #             {:term => {"brand.id" => params[:brand_id]}}
            #           ]
            #         }
            #       }
            # # if params[:subcategory_id]
            # #   query[:nested] = {
            # #     "path": "children",
            # #         "query": {
            # #           "bool": {
            # #             "must": [
            # #               { "match": {"categories.id": params[:subcategory_id]}}
            # #             ]
            # #           }
            # #         }
            # #   }
            # # end
      
            # result = Shop.search(
            #       query
            #   ).page(params[:page])
            # {products: result}
          end
        end
      end      
    end
  end
end