
module API
  module V1
    module Brands
      module Entities
        # this end point will return 6 products along with brand 
        # Date: 7 October 2016
        class ShowBrandWithProductEntity < API::BaseEntity
          root 'brands', 'brand'

          def self.entity_name
            'show_brand'
          end

          expose :id, documentation: { type: 'Integer', desc: "ID of the brand" }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: "Name of the brand" }, format_with: :string
          expose :image_url, documentation: { type: 'String', desc: "An URL directing to a photo." }, format_with: :string
          expose :logo_url, documentation: { type: 'String', desc: "An URL directing to a photo." }, format_with: :string
          expose :products, documentation: {type: 'show_product', is_array: true }do |brand, options|
            API::V2::Retailers::Entities::ShowProductEntity.represent retailer_products , options.merge(retailer_id: request_params["retailer_id"])
          end
          expose :products_count, documentation: {type: 'Integer', desc: "Count of products for this brand" }
          expose :slug, documentation: { type: 'String', desc: "URL friendly name" }, format_with: :string

          private

          def image_url
            object.brand_logo_1.present? ? object.brand_logo_1.url(:medium) : object.photo.url(:medium)
          end

          def logo_url
            object.brand_logo_2.present? ? object.brand_logo_2.url(:medium) : object.photo.url(:medium)
          end

          # this method will get request parameters
          def request_params
            self.options[:env]["rack.request.query_hash"]
          end

          # find the retailer from request query
          def retailer
            Retailer.joins(:products).find_by(id: request_params["retailer_id"])
          end

          # based on params find the products
          def show_products
            if retailer
              category_id = options[:category_id] || options[:env]["rack.request.query_hash"]["category_id"]
              if object.id && category_id
                retailer_products = retailer.products.joins(:product_categories).where({brand_id: object.id, product_categories: {category_id: category_id}})
              elsif object.id
                retailer_products = retailer.products.where(brand_id: object.id)
              elsif options[:category_id]
                retailer_products = retailer.products.joins(:product_categories).where(product_categories: {category_id: category_id})
              else
                retailer_products = retailer.products
              end
              retailer_products
            end
          end

          def retailer_products
            # show_products.order('RANDOM()').first(6)
            show_products
          end

          def products_count
            show_products.count
          end

        end                
      end
    end
  end
end