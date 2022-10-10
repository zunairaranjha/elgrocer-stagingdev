# frozen_string_literal: true

module API
  module V1
    module Orders
      class CreatePositions < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :orders do
          desc 'lists all orders of a shopper or retailer (depending on who is requesting it)', entity: API::V1::Orders::Entities::ShowEntity
          params do
            requires :order_id, type: Integer, desc: 'Ids of order', documentation: { example: '123434' }
            requires :products, type: Array do
              requires :amount, type: Integer, desc: 'Desired amount of product', documentation: { example: '5' }
              requires :product_id, type: Integer, desc: 'Desired amount of product', documentation: { example: '5' }
            end
          end

          post '/create_positions' do
            order = Order.select(:id, :retailer_id).find_by(id: params[:order_id])
            error!(CustomErrors.instance.order_not_found, 421) unless order
            retailer = Retailer.select(:id, :commission_value).find_by(id: order.retailer_id)
            products_ids = params[:products].map do |obj|
              obj[:product_id]
            end
            new_positions = []
            db_products = Product.unscoped.includes(:brand, :subcategories, :categories).where(id: products_ids)
            db_shops = Shop.unscoped.where(product_id: products_ids, retailer_id: retailer.id)

            db_products.each do |pr|
              db_shop = db_shops.select { |sh| sh.product_id == pr.id }[0]

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
                amount: params[:products].detect { |prod| prod[:product_id] == pr.id }[:amount],
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
              new_positions.push(order_position)
            end

            OrderPosition.transaction do
              OrderPosition.create(new_positions)
            end
            order.update(total_value: order.total_price_without_discount, updated_at: Time.now)
            true
          end
        end
      end
    end
  end
end
