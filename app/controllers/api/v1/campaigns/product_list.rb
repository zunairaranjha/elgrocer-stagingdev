module API
  module V1
    module Campaigns
      class ProductList < Grape::API
        version 'v1', using: :path
        format :json

        resource :campaigns do
          desc 'To get Campaigns'

          params do
            requires :retailer_id, type: Integer, desc: 'Id of the Retailer', documentation: { example: 16 }
            requires :campaign_id, type: Integer, desc: 'Campaign Id', documentation: { example: 1 }
            requires :limit, type: Integer, desc: 'Limit', documentation: { example: 10 }
            requires :offset, type: Integer, desc: 'Offset', documentation: { example: 0 }
            requires :delivery_time, type: Float, desc: 'Promotional time', documentation: { example: 9876543234567.0 }
          end

          get '/products/list' do
            retailer = Retailer.select(:id, :with_stock_level).find_by_id(params[:retailer_id])
            error!(CustomErrors.instance.retailer_not_found, 421) unless retailer
            Product.retailer_of_product = retailer.id
            products = Product.joins(:retailer_shops).where(shops: { promotion_only: false })
            products = products.joins("INNER JOIN campaigns ON products.id = ANY(campaigns.product_ids) AND campaigns.id = #{params[:campaign_id]}")
            products = products.select_info
            sql1 = products.to_sql

            products = Product.joins(:retailer_shop_promotions, :retailer_shops).where(shops: { is_promotional: true, promotion_only: true })
            products = products.joins("INNER JOIN campaigns ON products.id = ANY(campaigns.product_ids) AND campaigns.id = #{params[:campaign_id]}")
            products = products.where("#{params[:delivery_time]} BETWEEN shop_promotions.start_time AND shop_promotions.end_time")
            products = products.select_info
            sql2 = products.to_sql

            products = Product.find_by_sql("(#{sql1}) UNION (#{sql2}) ORDER BY product_rank desc, id desc offset #{params[:offset]} limit #{params[:limit]}")
            ActiveRecord::Associations::Preloader.new.preload(products, %i[brand product_categories categories subcategories retailer_shops])
            ActiveRecord::Associations::Preloader.new.preload(products, :retailer_shop_promotions, { where: ("#{params[:delivery_time]} BETWEEN shop_promotions.start_time AND shop_promotions.end_time"), order: %i[end_time start_time] })
            # shop_ids = products.map(&:shop_id)
            # available_quantity = Redis.current.mapped_hmget('shops', *shop_ids) unless shop_ids.blank?
            # present products, with: API::V2::Products::Entities::ListEntity, available_quantity: available_quantity
            present products, with: API::V2::Products::Entities::ListEntity, retailer_with_stock: retailer.with_stock_level

          end
        end
      end
    end
  end
end

