# frozen_string_literal: true

module API
  module V2
    module ShopperCartProducts
      class Index < Grape::API
        include TokenAuthenticable
        version 'v2', using: :path
        format :json

        resource :shopper_cart_products do
          desc 'List of all products of a cart for current shopper. Requires authentication', entity: API::V1::ShopperCartProducts::Entities::ShowEntity
          params do
            requires :retailer_id, desc: 'Retailer id/slug'
          end

          get do
            if params[:retailer_id].to_i.zero?
              error!({ error_code: 401, error_message: 'Retailet not found' }, 401)
            elsif current_shopper.blank?
              error!({ error_code: 401, error_message: 'You are not logged in!' }, 401)
            else
              result = ShopperCartProduct.includes(:shop, product: %i[brand categories subcategories])
              result = result.where({ shopper_id: current_shopper.id })
              result = result.where({ retailer_id: params[:retailer_id].to_i })
              ActiveRecord::Associations::Preloader.new.preload(result, :current_promotions, { where: ("retailer_id = #{params[:retailer_id]} AND #{(Time.now.utc.to_f * 1000).floor} BETWEEN shop_promotions.start_time AND shop_promotions.end_time"), order: %i[end_time start_time] })
              # shop_ids = result.map(&:shop_id)
              # available_quantity = Redis.current.mapped_hmget('shops', *shop_ids) unless shop_ids.blank?
              API::V2::ShopperCartProducts::Entities::ShowEntity.represent result, root: false #, available_quantity: available_quantity
            end
          end

          desc 'List of all products of a cart for current shopper. Requires authentication'
          params do
            requires :retailer_id, type: Integer, desc: 'Retailer id', documentation: { example: 16 }
            requires :delivery_time, type: Float, desc: 'Delivery Time', documentation: { example: 123456789000 }
          end

          get '/list' do
            result = cart_for_shopper
            API::V2::ShopperCartProducts::Entities::ListEntity.represent result, root: false
          end

          desc 'List of all products of a cart for current shopper. Requires authentication'
          params do
            requires :retailer_id, type: Integer, desc: 'Retailer id', documentation: { example: 16 }
            requires :delivery_time, type: Float, desc: 'Delivery Time', documentation: { example: 123456789000 }
            optional :order_id, type: Integer, desc: 'Order Id', documentation: { example: 123469087 }
          end

          get '/index' do
            result = cart_for_shopper
            reserved_quantity = Redis.current.hgetall("order_#{params[:order_id]}") if params[:order_id].present?
            API::V2::ShopperCartProducts::Entities::ListEntity.represent result, root: false, cart_retailer: @cart_retailer, reserved_quantity: reserved_quantity
          end
        end

        helpers do
          def cart_for_shopper
            error!(CustomErrors.instance.not_login, 421) unless current_shopper
            @cart_retailer = Retailer.select(:id, :with_stock_level).find_by_id(params[:retailer_id])
            error!(CustomErrors.instance.retailer_not_found, 421) unless @cart_retailer
            Product.retailer_of_product = params[:retailer_id]
            result = ShopperCartProduct.includes(:shop, product: %i[brand categories subcategories])
            result = result.where(shopper_id: current_shopper.id, retailer_id: params[:retailer_id])
            ActiveRecord::Associations::Preloader.new.preload(result, :current_promotions, { where: ("retailer_id = #{params[:retailer_id]} AND #{params[:delivery_time]} BETWEEN shop_promotions.start_time AND shop_promotions.end_time"), order: %i[end_time start_time] })
            ActiveRecord::Associations::Preloader.new.preload(result, [product: [:retailer_shop_promotions]], { where: ("#{params[:delivery_time]} BETWEEN shop_promotions.start_time AND shop_promotions.end_time"), order: %i[end_time start_time] })
            result
          end
        end
      end
    end
  end
end
