module API
  module V2
    module Products
      module Entities
        class ShowBrandWithProductEntity < API::BaseEntity
          def self.entity_name
            'show_brand'
          end

          expose :id, documentation: { type: 'Integer', desc: 'ID of the brand' }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: 'Name of the brand' }, format_with: :string
          expose :slug, documentation: { type: 'String', desc: 'URL friendly name' }, format_with: :string
          expose :image_url, documentation: { type: 'String', desc: 'An URL directing to a photo.' }, format_with: :string
          expose :products do |brand, options|
            # API::V2::Products::Entities::ListEntity.represent show_products, available_quantity: available_quantity
            API::V2::Products::Entities::ListEntity.represent show_products, retailer_with_stock: retailer.with_stock_level
          end
          expose :slug, documentation: { type: 'String', desc: 'URL friendly name' }, format_with: :string
          expose :seo_data, documentation: { type: 'String', desc: 'SEO Data' }, format_with: :string, if: Proc.new { |obj| options[:web] }

          private

          def image_url
            object.brand_logo_1.present? ? object.brand_logo_1.url(:medium) : object.photo.url(:medium)
          end

          def request_params
            self.options[:env]['rack.request.query_hash']
          end

          # find the retailer from request query
          def retailer
            @retailer ||= options[:retailer]
          end

          def subcategory_id
            @category ||= options[:subcategory_id]
          end

          # based on params find the products
          def show_products
            @show_products ||=
              if retailer
                products_cached = Rails.cache.fetch("category_brands/products/#{retailer.id}/#{subcategory_id}/brand/#{object.id}/delivery_time/#{request_params['delivery_time']}/limit/#{request_params['products_limit']}/offset/#{request_params['products_offset']}", expires_in: (retailer.with_stock_level ? 1 : 50).minutes) do
                  retailer_products = retailer.products.where(brand_id: object.id).where(shops: { promotion_only: false })
                  if subcategory_id.to_i == 1 or subcategory_id.to_s =~ /promotion|offer/
                    retailer_products = retailer_products.joins("INNER JOIN shop_promotions ON shop_promotions.product_id = products.id AND shop_promotions.is_active = 't' AND shop_promotions.retailer_id = retailers.id AND #{request_params['delivery_time']} BETWEEN shop_promotions.start_time AND shop_promotions.end_time")
                  else
                    retailer_products = retailer_products.joins(:product_categories).where(product_categories: { category_id: subcategory_id })
                  end
                  retailer_products = retailer_products.select_info
                  sql1 = retailer_products.to_sql
                  retailer_products = Product.joins(:retailer_shops).where(brand_id: object.id).where(shops: { is_promotional: true, promotion_only: true })
                  retailer_products = retailer_products.joins("INNER JOIN shop_promotions ON shop_promotions.product_id = products.id AND shop_promotions.is_active = 't' AND shop_promotions.retailer_id = #{retailer.id} AND #{request_params['delivery_time']} BETWEEN shop_promotions.start_time AND shop_promotions.end_time")
                  retailer_products = retailer_products.joins(:product_categories).where(product_categories: { category_id: subcategory_id }) unless subcategory_id.to_i == 1 or subcategory_id.to_s =~ /promotion|offer/
                  retailer_products = retailer_products.select_info
                  sql2 = retailer_products.to_sql
                  retailer_products = Product.find_by_sql("(#{sql1}) UNION (#{sql2}) ORDER BY product_rank, id desc LIMIT #{request_params['products_limit']} OFFSET #{request_params['products_offset']}")
                  ActiveRecord::Associations::Preloader.new.preload(retailer_products, [:brand, :categories, :subcategories])
                  ActiveRecord::Associations::Preloader.new.preload(retailer_products, :retailer_shop_promotions, where: ("#{request_params['delivery_time']} BETWEEN shop_promotions.start_time AND shop_promotions.end_time"))
                  retailer_products.to_a
                end
                products_cached
              else
                Array.new
              end
          end

          # def available_quantity
          #   shop_ids = show_products.map(&:shop_id)
          #   Redis.current.mapped_hmget('shops', *shop_ids) unless shop_ids.blank?
          # end
        end
      end
    end
  end
end
