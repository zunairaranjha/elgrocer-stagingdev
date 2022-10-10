# frozen_string_literal: true

module API
  module V3
    module Categories
      class CategoryShopperBrands < Grape::API
        version 'v3', using: :path
        format :json

        resource :categories do
          desc "List of all category's brands. Requires authentication.", entity: API::V2::Categories::Entities::CategoryBrandsEntity
          params do
            requires :category_id, desc: 'Id or Slug of category parent', documentation: { example: "1 or water" }
            requires :retailer_id, desc: 'Id or Slug of Retailer', documentation: { example: "1 or baorganic" }
            optional :limit, type: Integer, desc: 'Limit of Brands', documentation: { example: 20 }
            optional :offset, type: Integer, desc: 'Offset of Brands', documentation: { example: 10 }
            optional :products_limit, type: Integer, desc: 'Limit of Brands', documentation: { example: 20 }
            optional :products_offset, type: Integer, desc: 'Offset of Brands', documentation: { example: 10 }
          end
          get '/shopper/brands' do
            category = params[:category_id].to_i > 0 ? Category.select(:id).find_by(id: params[:category_id]) : Category.select(:id).find(params[:category_id])
            retailer = params[:retailer_id][/\p{L}/] ? Retailer.select(:id).find_by(slug: params[:retailer_id]) : Retailer.select(:id).find_by(id: params[:retailer_id])

            brands = Brand.joins(:subcategories, :shops, :products)
            brands = brands.where("product_categories.category_id = ?", category) if params['category_id'].to_i != 1
            if params['category_id'].to_i == 1
              brands = brands.joins("JOIN shop_promotions ON shop_promotions.product_id = products.id AND shop_promotions.retailer_id = #{retailer.id} AND shop_promotions.is_active = 't' AND #{(Time.now.utc.to_f * 1000).floor} BETWEEN shop_promotions.start_time AND shop_promotions.end_time")
              brands = brands.where("shops.is_promotional = ?", true)
            end
            brands = brands.where("shops.retailer_id = ?", retailer.id)
                           .where('products_brands_join.id = product_categories.product_id')
                           .select("brands.id, brands.name, brands.name_ar, brands.photo_file_name,brands.brand_logo_1_file_name,brands.brand_logo_2_file_name, brands.slug, brands.priority,brands.priority + sum(shops.product_rank) brand_rank")
                           .group('brands.id').reorder('brand_rank desc, brands.priority desc, brands.id desc')
                           .limit(params[:limit].to_i + 1).offset(params[:offset].to_i)

            brands = brands.select("brands.seo_data") if request.headers['Referer']
            is_next = brands.length > params[:limit].to_i

            present brands.to_a.first(params[:limit].to_i), with: API::V3::Categories::Entities::ShowBrandWithProductEntity, params: { retailer: retailer, category: category }, web: request.headers['Referer']
            present :next, is_next

          end
        end
      end
    end
  end
end