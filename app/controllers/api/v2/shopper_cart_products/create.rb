# frozen_string_literal: true

module API
  module V2
    module ShopperCartProducts
      class Create < Grape::API
        include TokenAuthenticable
        version 'v2', using: :path
        format :json

        resource :shopper_cart_products do
          desc 'Allows adding of a product into cart for a shopper. Requires authentication'
          params do
            requires :retailer_id, type: Integer, desc: 'Retailer id'
            requires :product_id, type: Integer, desc: 'Product id'
            requires :quantity, type: Integer, desc: 'Product quantity'
            requires :delivery_time, type: Float, desc: 'Time of the delivery', documentation: { example: 123456789000 }
            optional :order_id, type: Integer, desc: 'Order Id', documentation: { example: 234567890 }
          end

          post '/create_update' do
            error!(CustomErrors.instance.only_shopper_can_change, 421) unless current_shopper
            retailer = Retailer.select(:id, :with_stock_level).find_by_id(params[:retailer_id])
            error!(CustomErrors.instance.retailer_not_found, 421) unless retailer
            if (shopper_cart_product = ShopperCartProduct.find_by(retailer_id: params[:retailer_id], product_id: params[:product_id], shopper_id: current_shopper.id)) && params[:quantity].positive?
              check_stock(retailer)
              shopper_cart_product.quantity = params[:quantity]
              unless shopper_cart_product.delivery_time.to_f == params[:delivery_time].to_f
                shopper_cart_product.shop_promotion_id = shop_promotion&.id
                shopper_cart_product.delivery_time = params[:delivery_time]
              end
              shopper_cart_product.date_time_offset = request.headers['Datetimeoffset']
              shopper_cart_product.save
            elsif params[:quantity].positive?
              check_stock(retailer)
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
            { message: 'ok', product_id: params[:product_id], available_quantity: retailer.with_stock_level ? total_quantity : -1 }
          end
        end

        helpers do
          def check_stock(retailer)
            return unless retailer.with_stock_level && params[:quantity].positive? && shop && total_quantity < params[:quantity]

            error!(CustomErrors.instance.product_quantity_limit(total_quantity, params[:product_id]), 421)
          end

          def shop
            @shop ||= Shop.unscoped.joins('JOIN products ON products.id = shops.product_id').select(:id, :available_for_sale).where(retailer_id: params[:retailer_id], product_id: params[:product_id]).first
          end

          def shop_promotion
            @shop_promotion ||= ShopPromotion.where(product_id: params[:product_id], retailer_id: params[:retailer_id]).where('? BETWEEN start_time AND end_time', params[:delivery_time]).order(:end_time, :start_time).first
          end

          def reserved_quantity
            params[:order_id] ? Redis.current.hmget("order_#{params[:order_id]}", params[:product_id]).first.to_i : 0
          end

          def total_quantity
            @total_quantity ||= shop&.available_for_sale.to_i + reserved_quantity
          end
        end
      end
    end
  end
end
