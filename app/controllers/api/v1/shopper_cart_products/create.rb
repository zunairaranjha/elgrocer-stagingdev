# frozen_string_literal: true

module API
  module V1
    module ShopperCartProducts
      class Create < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :shopper_cart_products do
          desc 'Allows adding of a product into cart for a shopper. Requires authentication', entity: API::V1::ShopperCartProducts::Entities::ShowEntity
          params do
            requires :retailer_id, type: Integer, desc: 'Retailer id'
            requires :product_id, type: Integer, desc: 'Product id'
            requires :quantity, type: Integer, desc: 'Product quantity'
          end

          post do
            if current_retailer
              error!({ error_code: 401, error_message: 'Only shoppers can add!' }, 401)
            else
              full_params = params.merge(shopper_id: current_shopper.id, date_time_offset: request.headers['Datetimeoffset'])
              ::ShopperCartProducts::Create.run(full_params)
              true
            end
          end

          desc 'Allows adding of a product into cart for a shopper. Requires authentication'
          params do
            requires :retailer_id, type: Integer, desc: 'Retailer id'
            requires :product_id, type: Integer, desc: 'Product id'
            requires :quantity, type: Integer, desc: 'Product quantity'
            requires :delivery_time, type: Float, desc: 'Time of the delivery', documentation: { example: 123456789000 }
          end

          post '/create_update' do
            error!(CustomErrors.instance.only_shopper_can_change, 421) unless current_shopper
            retailer = Retailer.select(:id, :with_stock_level).find_by(id: params[:retailer_id])
            error!(CustomErrors.instance.retailer_not_found, 421) unless retailer
            shopper_cart_product = ShopperCartProduct.find_by(retailer_id: params[:retailer_id], product_id: params[:product_id], shopper_id: current_shopper.id)
            if shopper_cart_product && params[:quantity].positive?
              shopper_cart_product.quantity = params[:quantity]
              unless shopper_cart_product.delivery_time.to_f == params[:delivery_time].to_f
                shop_promotion = ShopPromotion.where(product_id: params[:product_id], retailer_id: params[:retailer_id]).where('? BETWEEN start_time AND end_time', params[:delivery_time]).order(:end_time, :start_time).first
                shopper_cart_product.shop_promotion_id = shop_promotion&.id
                shopper_cart_product.delivery_time = params[:delivery_time]
              end
              shopper_cart_product.date_time_offset = request.headers['Datetimeoffset']
              shopper_cart_product.save
            elsif params[:quantity].positive?
              shop = Shop.unscoped.joins('JOIN products ON products.id = shops.product_id').select(:id).where(retailer_id: params[:retailer_id], product_id: params[:product_id]).first
              shop_promotion = ShopPromotion.where(product_id: params[:product_id], retailer_id: params[:retailer_id]).where('? BETWEEN start_time AND end_time', params[:delivery_time]).order(:end_time, :start_time).first
              # error!(CustomErrors.instance.product_not_found, 421) unless (shop or shop_promotion)
              begin
                ShopperCartProduct.create(retailer_id: params[:retailer_id],
                                          product_id: params[:product_id],
                                          shopper_id: current_shopper.id,
                                          quantity: params[:quantity],
                                          shop_id: shop&.id,
                                          shop_promotion_id: shop_promotion&.id,
                                          date_time_offset: request.headers['Datetimeoffset'])
              rescue
                error!(CustomErrors.instance.something_wrong, 421)
              end
            else
              shopper_cart_product&.destroy
            end
            true
          end
        end
      end
    end
  end
end