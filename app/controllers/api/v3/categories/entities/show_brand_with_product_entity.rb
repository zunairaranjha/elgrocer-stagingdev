# frozen_string_literal: true

# this end point will return 6 products along with brand
# Date: 7 October 2016
module API
  module V3
    module Categories
      module Entities
        class ShowBrandWithProductEntity < API::BaseEntity
          root 'brands', 'brand'

          def self.entity_name
            'show_brand'
          end

          expose :id, documentation: { type: 'Integer', desc: "ID of the brand" }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: "Name of the brand" }, format_with: :string
          expose :slug, documentation: { type: 'String', desc: "URL friendly name" }, format_with: :string
          expose :image_url, documentation: { type: 'String', desc: "An URL directing to a photo." }, format_with: :string
          expose :logo_url, documentation: { type: 'String', desc: "An URL directing to a photo." }, format_with: :string
          expose :products do |brand, options|
            API::V3::Categories::Entities::ShowProductEntity.represent retailer_products, options.merge(retailer_id: retailer.id)
          end
          # expose :retailer_products, as: :products, with: API::V2::Retailers::Entities::ShowProductEntity, documentation: {type: 'show_product', is_array: true }
          expose :products_count, documentation: { type: 'Integer', desc: "Count of products for this brand" }
          expose :products_is_next, documentation: { type: 'Boolean', desc: "Are there more products under this brand?" }, format_with: :bool
          expose :slug, documentation: { type: 'String', desc: "URL friendly name" }, format_with: :string
          expose :seo_data, documentation: { type: 'String', desc: "SEO Data" }, format_with: :string, if: Proc.new { |obj| options[:web] }

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
            # Retailer.joins(:products).find_by(id: request_params["retailer_id"])
            @retailer ||= (options[:params][:retailer] || Retailer.find(request_params["retailer_id"]))
          end

          def category
            @category ||= (options[:params][:category] || Category.find(request_params["category_id"]))
          end

          # based on params find the products
          def show_products
            if retailer
              # category_id = Category.find(options[:category_id] || request_params["category_id"]).id
              # category_id = request_params["category_id"]
              retailer_products = retailer.products.where(brand_id: object.id)
              retailer_products = retailer_products.includes(:brand, :categories, :subcategories)
              retailer_products = retailer_products.joins(:product_categories).where(product_categories: { category_id: category.id }) if category.id != 1 #if category_id
              retailer_products = retailer_products.select('products.*,shops.price_currency,shops.price_dollars,shops.price_cents,shops.is_available,shops.is_published,shops.is_promotional')
              retailer_products.order('shops.product_rank desc, shops.product_id desc')
              if category.id == 1
                retailer_products = retailer_products.where(shops: { is_promotional: true })
                retailer_products = retailer_products.joins("JOIN shop_promotions ON shop_promotions.retailer_id = shops.retailer_id AND shop_promotions.product_id = shops.product_id AND shop_promotions.is_active = 't' AND #{(Time.now.utc.to_f * 1000).floor} BETWEEN shop_promotions.start_time AND shop_promotions.end_time")
              end
              ActiveRecord::Associations::Preloader.new.preload(retailer_products, :shop_promotions, { where: ("retailer_id = #{retailer.id} AND #{(Time.now.utc.to_f * 1000).floor} BETWEEN shop_promotions.start_time AND shop_promotions.end_time"), order: [:end_time, :start_time] })
              retailer_products
            end
          end

          def retailer_products
            result ||= show_products.limit(request_params['products_limit']).offset(request_params['products_offset'])
            # category_id = options[:category_id] || options[:env]["rack.request.query_hash"]["category_id"]
            # result ||= Shop.search_products('', request_params["retailer_id"], object.id, [category_id], 200, 0)
            # Shop.search_products('', request_params["retailer_id"], object.id, [category_id], request_params[:limit], request_params[:offset])
          end

          def products_count
            show_products.count('shops.id')
            # retailer_products.results.total
          end

          def products_is_next
            if request_params['products_limit'].present?
              products_count > request_params['products_limit'].to_i + request_params['products_offset'].to_i
            else
              false
            end
          end

        end
      end
    end
  end
end