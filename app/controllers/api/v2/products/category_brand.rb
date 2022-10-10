# frozen_string_literal: true

module API
  module V2
    module Products
      class CategoryBrand < Grape::API
        version 'v2', using: :path
        format :json
        helpers Concerns::ProductHelper

        resource :products do
          desc 'List of the products'

          params do
            requires :retailer_id, desc: 'Retailer Id', documentation: { example: 16 }
            requires :limit, type: Integer, desc: 'Limit', documentation: { example: 10 }
            requires :offset, type: Integer, desc: 'Offset', documentation: { example: 0 }
            requires :delivery_time, desc: 'delivery-time', documentation: { example: 90 }
            requires :subcategory_id, desc: 'Category Id', documentation: { example: 100 }
            requires :products_limit, type: Integer, desc: 'Limit of Brands', documentation: { example: 20 }
            requires :products_offset, type: Integer, desc: 'Offset of Brands', documentation: { example: 10 }
          end

          get '/category_brands' do
            error!({ error_code: 404, error_message: 'Retailer Not Found' }, 404) unless retailer_id

            brands = Brand.joins(:product_categories)
            brands = brands.joins("INNER JOIN shops ON shops.product_id = products.id AND shops.is_published = 't' AND shops.is_available = 't' AND shops.retailer_id = #{retailer_id.id} AND shops.promotion_only = 'f'")
            Product.retailer_of_product = retailer_id.id
            if params[:subcategory_id].to_i == 1 || params[:subcategory_id].to_s =~ /promotion|offer/
              brands = brands.joins("INNER JOIN shop_promotions ON products.id = shop_promotions.product_id AND shop_promotions.is_active = 't' AND shop_promotions.retailer_id = #{retailer_id.id} AND #{params[:delivery_time]} BETWEEN shop_promotions.start_time AND shop_promotions.end_time")
            else
              brands = brands.where('product_categories.category_id = ?', subcategory_id.id)
            end
            brands = brands.select('brands.id, brands.name, brands.name_ar, brands.photo_file_name,brands.brand_logo_1_file_name,brands.brand_logo_2_file_name, brands.slug, brands.priority, brands.priority + sum(shops.product_rank) AS product_rank')
            brands = brands.group('brands.id')
            sql1 = brands.to_sql

            brands = Brand.joins(:product_categories)
            brands = brands.joins("INNER JOIN shops ON shops.product_id = products.id AND shops.is_published = 't' AND shops.is_available = 't' AND shops.retailer_id = #{retailer_id.id} AND shops.promotion_only = 't' AND shops.is_promotional = 't'")
            brands = brands.joins("INNER JOIN shop_promotions ON shop_promotions.product_id = products.id AND shop_promotions.is_active = 't' AND shop_promotions.retailer_id = #{retailer_id.id} AND #{params[:delivery_time]} BETWEEN shop_promotions.start_time AND shop_promotions.end_time")
            brands = brands.where('product_categories.category_id = ?', subcategory_id.id) unless params[:subcategory_id].to_i == 1 || params[:subcategory_id].to_s =~ /promotion|offer/
            brands = brands.select('brands.id, brands.name, brands.name_ar, brands.photo_file_name,brands.brand_logo_1_file_name,brands.brand_logo_2_file_name, brands.slug, brands.priority, brands.priority + sum(shops.product_rank) AS product_rank')
            brands = brands.group('brands.id')
            sql2 = brands.to_sql
            brands = Brand.select('b.id, b.name, b.name_ar, b.photo_file_name,b.brand_logo_1_file_name,b.brand_logo_2_file_name, b.slug, SUM(b.product_rank)').from(("((#{sql1}) UNION (#{sql2})) AS b"), :b)
                          .group('b.id,b.name, b.name_ar, b.photo_file_name,b.brand_logo_1_file_name,b.brand_logo_2_file_name, b.slug').order('SUM(b.product_rank) DESC').limit(params[:limit]).offset(params[:offset])
            present brands, with: API::V2::Products::Entities::ShowBrandWithProductEntity, retailer: retailer_id, subcategory_id: subcategory_id.id
          end
        end
      end
    end
  end
end
