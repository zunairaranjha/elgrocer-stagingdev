# frozen_string_literal: true

module API
  module V2
    module Orders
      class CreatePositions < Grape::API
        include TokenAuthenticable
        version 'v2', using: :path
        format :json

        resource :orders do
          desc 'Update Substitutions of Order'
          params do
            requires :order_id, type: Integer, desc: 'Ids of order', documentation: { example: '123434' }
            requires :amount, values: ->(v) { v.positive? }, type: Integer, desc: 'Desired amount of product', documentation: { example: '5' }
            requires :product_id, values: ->(v) { v.positive? }, type: Integer, desc: 'Desired amount of product', documentation: { example: '5' }
          end

          post '/create_positions' do
            error!(CustomErrors.instance.not_allowed, 421) unless current_employee
            order = Order.select(:id, :retailer_id, :status_id).find_by(id: params[:order_id])
            error!(CustomErrors.instance.order_not_found, 421) unless order
            retailer = Retailer.select(:id, :commission_value, :with_stock_level).find_by(id: order.retailer_id)
            pr = Product.unscoped.includes(:brand, :subcategories, :categories).where(id: params[:product_id]).first
            error!(CustomErrors.instance.product_not_found, 421) unless pr
            db_shop = Shop.unscoped.where(product_id: params[:product_id], retailer_id: retailer.id).first
            if retailer.with_stock_level && db_shop&.available_for_sale.to_i < params[:amount]
              error!(CustomErrors.instance.product_quantity_limit(db_shop.available_for_sale.to_i, pr.id), 421)
            end

            shop_id = db_shop&.id
            shop_price_cents = db_shop&.price_cents.to_i
            shop_price_dollars = db_shop&.price_dollars.to_i
            shop_price_currency = db_shop&.price_currency || 'AED'
            shop_is_promotional = db_shop&.is_promotional || false

            shop_commission_value = retailer.commission_value || 0

            product_brand_name = pr.brand&.name || 'Other'
            product_category_name = pr.categories.first&.name || 'Other'
            product_subcategory_name = pr.subcategories.first&.name || 'Other'

            order_position = {
              order_id: order.id,
              product_id: pr.id,
              shop_id: shop_id,
              amount: params[:amount],
              product_barcode: pr.barcode,
              brand_id: pr.brand_id,
              product_brand_name: product_brand_name,
              product_name: pr.name,
              product_description: pr.description,
              product_shelf_life: pr.shelf_life,
              product_size_unit: pr.size_unit,
              product_country_alpha2: pr.country_alpha2,
              product_location_id: pr.location_id,
              category_id: pr.categories[0].try(:id),
              product_category_name: product_category_name,
              subcategory_id: pr.subcategories[0].try(:id),
              product_subcategory_name: product_subcategory_name,
              shop_price_cents: shop_price_cents,
              shop_price_dollars: shop_price_dollars,
              shop_price_currency: shop_price_currency,
              commission_value: shop_commission_value,
              is_promotional: shop_is_promotional,
              date_time_offset: request.headers['Datetimeoffset']
            }

            OrderPosition.transaction do
              OrderPosition.create(order_position)
            end
            if retailer.with_stock_level
              db_shop.available_for_sale = db_shop.available_for_sale.to_i - params[:amount]
              db_shop.is_available = db_shop.available_for_sale.zero? ? false : db_shop.is_available
              db_shop.save
            end
            order.update(total_value: order.total_price_without_discount, updated_at: Time.now)
            true
          end
        end
      end
    end
  end
end
