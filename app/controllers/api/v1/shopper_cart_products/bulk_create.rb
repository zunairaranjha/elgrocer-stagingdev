# frozen_string_literal: true

module API
  module V1
    module ShopperCartProducts
      class BulkCreate < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :shopper_cart_products do
          desc 'Allows adding of a product into cart for a shopper. Requires authentication', entity: API::V1::ShopperCartProducts::Entities::ShowEntity
          params do
            requires :retailer_id, type: Integer, desc: 'Retailer id'
            requires :products, type: Array do
              requires :product_id, type: Integer, desc: 'Product Id', documentation: { example: '5' }
              requires :quantity, type: Integer, desc: 'Product quantity', documentation: { example: '5' }
            end
          end

          post '/bulk_create' do
            if current_retailer
              error!({ error_message: 'Only shoppers can add!' })
            else
              full_params = params.merge(shopper_id: current_shopper.id)
              retailer = Retailer.find_by(id: params[:retailer_id])
              error!({ error_message: 'Retailer does not exist' }) unless retailer
              products = params[:products]
              shopper_cart_products = []
              products.each do |product|
                shopper_cart_product = ShopperCartProduct.find_or_initialize_by(retailer_id: retailer.id, shopper_id: full_params[:shopper_id], product_id: product[:product_id])
                # shopper_cart_product = {
                #   retailer_id: retailer.id,
                #   shopper_id: full_params[:shopper_id],
                #   product_id: product.product_id,
                #   quantity: product.quantity
                # }
                shopper_cart_product.update(quantity: product[:quantity])
                shopper_cart_products.push(shopper_cart_product)
              end
              # result = ShopperCartProduct.transaction do
              #   ShopperCartProduct.create(shopper_cart_products)
              # end
              if shopper_cart_products.any?
                true
              else
                false
              end
            end
          end

          desc 'Allows adding of a product into cart for a shopper. Requires authentication'
          params do
            requires :retailer_id, type: Integer, desc: 'Retailer id'
            requires :products, type: Array do
              requires :product_id, type: Integer, desc: 'Product Id', documentation: { example: '5' }
              requires :quantity, type: Integer, desc: 'Product quantity', documentation: { example: '5' }
            end
            requires :delivery_time, type: Float, desc: '"Delivery time"', documentation: { example: 2345678969899 }
          end

          post '/bulk_update' do
            error!(CustomErrors.instance.only_shopper_can_change, 421) unless current_shopper
            error!(CustomErrors.instance.retailer_not_found, 421) unless Retailer.where(id: params[:retailer_id]).exists?
            params[:products].each do |product|
              shopper_cart_product = ShopperCartProduct.find_by(retailer_id: params[:retailer_id], product_id: product[:product_id], shopper_id: current_shopper.id)
              if shopper_cart_product && (product[:quantity]).positive?
                shopper_cart_product.quantity = product[:quantity]
                if shopper_cart_product.delivery_time.to_f != params[:delivery_time].to_f
                  shop_promotion = ShopPromotion.where(product_id: product[:product_id], retailer_id: params[:retailer_id]).where('? BETWEEN start_time AND end_time', params[:delivery_time]).order(:end_time, :start_time).first
                  shopper_cart_product.shop_promotion_id = shop_promotion&.id
                  shopper_cart_product.delivery_time = params[:delivery_time]
                end
                shopper_cart_product.date_time_offset = request.headers['Datetimeoffset']
                shopper_cart_product.save
              elsif (product[:quantity]).positive?
                shop = Shop.unscoped.joins('JOIN products ON products.id = shops.product_id').select(:id).where(retailer_id: params[:retailer_id], product_id: product[:product_id]).first
                shop_promotion = ShopPromotion.where(product_id: product[:product_id], retailer_id: params[:retailer_id]).where('? BETWEEN start_time AND end_time', params[:delivery_time]).order(:end_time, :start_time).first
                # error!(CustomErrors.instance.product_not_found, 421) unless (shop or shop_promotion)
                begin
                  ShopperCartProduct.create(retailer_id: params[:retailer_id],
                                            product_id: product[:product_id],
                                            shopper_id: current_shopper.id,
                                            quantity: product[:quantity],
                                            shop_id: shop&.id,
                                            shop_promotion_id: shop_promotion&.id,
                                            date_time_offset: request.headers['Datetimeoffset'])
                rescue
                  error!(CustomErrors.instance.something_wrong, 421)
                end
              else
                shopper_cart_product&.destroy
              end
            end
            true
          end
        end
      end
    end
  end
end
