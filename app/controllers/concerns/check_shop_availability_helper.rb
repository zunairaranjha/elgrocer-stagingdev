# frozen_string_literal: true

module Concerns
  module CheckShopAvailabilityHelper
    extend Grape::API::Helpers

    def check_products_quantity
      return unless retailer.with_stock_level

      err_list = []
      @shop_list = []
      previous_products
      get_products.each do |pr|
        @previous_products.delete(pr.id)
        if get_product_qty(pr.id) > total_available_quantity(pr)
          err_list << { product_id: pr.id, available_quantity: total_available_quantity(pr) }
        else
          shop = Shop.new(id: pr.shop_id, available_for_sale: total_available_quantity(pr) - get_product_qty(pr.id),
                          updated_at: Time.now, price_cents: pr.price_cents, price_dollars: pr.price_dollars)
          shop.is_available = shop.available_for_sale.zero? ? false : shop.is_available
          @shop_list << shop
        end
      end
      error!(CustomErrors.instance.products_limited_stock(err_list), 421) unless err_list.blank?
      return if @previous_products.blank?

      shops = Shop.unscoped.where(retailer_id: retailer.id, product_id: @previous_products.keys)
      shops.each do |shop|
        shop.available_for_sale = shop.available_for_sale.to_i + @previous_products[shop.product_id].to_i
        shop.is_available = shop.available_for_sale.positive? ? true : shop.is_available
        shop.updated_at = Time.now
        @shop_list << shop
      end
    end

    def adjust_stock
      return if @shop_list.blank?

      Shop.transaction do
        Shop.import @shop_list.to_ary, on_duplicate_key_update: { conflict_target: %i[id], columns: %i[available_for_sale updated_at is_available] }
      end
      AlgoliaProductIndexingJob.perform_later(get_product_ids | @previous_products.keys)
    end

    def total_available_quantity(product)
      product.available_for_sale.to_i + product_reserved_quantity(product.id.to_s)
    end

    def product_reserved_quantity(product_id)
      params[:order_id] ? reserved_quantity[product_id].to_i : 0
    end

    def reserved_quantity
      @reserved_quantity ||= Redis.current.hgetall("order_#{params[:order_id]}")
    end

    # def previous_products
    #   @previous_products = {}
    #   return @previous_products if params[:order_id].blank? || @previous_products.present?
    #
    #   previous_products = OrderPosition.where(order_id: params[:order_id]).select(:product_id, :amount)
    #   previous_products.each { |pp| @previous_products[pp.product_id] = pp.amount }
    #   @previous_products
    # end
  end
end
