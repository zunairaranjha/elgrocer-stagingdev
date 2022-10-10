# frozen_string_literal: true

module API
  module V2
    module ShopperCartProducts
      class BulkCreate < Grape::API
        include TokenAuthenticable
        version 'v2', using: :path
        format :json

        resource :shopper_cart_products do
          desc 'Allows adding of products into cart for a shopper. Requires authentication'
          params do
            requires :retailer_id, type: Integer, desc: 'Retailer id'
            requires :products, type: Array do
              requires :product_id, type: Integer, desc: 'Product Id', documentation: { example: '5' }
              requires :quantity, type: Integer, desc: 'Product quantity', documentation: { example: '5' }
            end
            requires :delivery_time, type: Float, desc: '"Delivery time"', documentation: { example: 2345678969899 }
          end

          post '/bulk_create_update' do
            error!(CustomErrors.instance.only_shopper_can_change, 421) unless current_shopper
            retailer = Retailer.select(:id, :with_stock_level).find_by_id(params[:retailer_id])
            # @error_list_message = []
            @list_message = []
            error!(CustomErrors.instance.retailer_not_found, 421) unless retailer
            params[:products].each do |product|
              if (shopper_cart_product = ShopperCartProduct.find_by(retailer_id: params[:retailer_id], product_id: product[:product_id], shopper_id: current_shopper.id)) && (product[:quantity]).positive?
                shop = fetch_shop(params[:retailer_id], product[:product_id])
                # next if check_stock(retailer, product, shop)
                shopper_cart_product.quantity = product[:quantity]
                if shopper_cart_product.delivery_time.to_f != params[:delivery_time].to_f
                  shop_promotion = ShopPromotion.where(product_id: product[:product_id], retailer_id: params[:retailer_id]).where('? BETWEEN start_time AND end_time', params[:delivery_time]).order(:end_time, :start_time).first
                  shopper_cart_product.shop_promotion_id = shop_promotion&.id
                  shopper_cart_product.delivery_time = params[:delivery_time]
                end
                shopper_cart_product.date_time_offset = request.headers['Datetimeoffset']
                shopper_cart_product.save
              elsif (product[:quantity]).positive?
                shop = fetch_shop(params[:retailer_id], product[:product_id])
                # next if check_stock(retailer, product, shop)
                shop_promotion = ShopPromotion.where(product_id: product[:product_id], retailer_id: params[:retailer_id]).where('? BETWEEN start_time AND end_time', params[:delivery_time]).order(:end_time, :start_time).first
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
                shop = nil
                shopper_cart_product&.destroy
              end
              @list_message << { product_id: product[:product_id], available_quantity: retailer.with_stock_level ? shop&.available_for_sale.to_i : -1 }
            end
            # if @error_list_message.blank?
            { message: @list_message }
            # else
            #   error!(@error_list_message, 421)
            # end
          end
        end

        helpers do
          # def check_stock(retailer, product, shop)
          #   if retailer.with_stock_level && product[:quantity].positive? && shop && shop.available_for_sale.to_i < product[:quantity]
          #     @error_list_message << CustomErrors.instance.product_quantity_limit(shop.available_for_sale.to_i, product[:product_id])
          #     return true
          #   end
          #   false
          # end

          def fetch_shop(retailer_id, product_id)
            Shop.unscoped.joins('JOIN products ON products.id = shops.product_id').select(:id, :available_for_sale).where(retailer_id: retailer_id, product_id: product_id).first
          end
        end
      end
    end
  end
end
