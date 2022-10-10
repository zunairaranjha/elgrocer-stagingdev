# frozen_string_literal: true

module API
  module V1
    module Products
      class AvailableQuantity < Grape::API
        version 'v1', using: :path
        format :json

        resource :products do
          desc 'This api is to check available quantity of the product'

          params do
            requires :retailer_id, type: Integer, desc: 'Retailer Id', documentation: { example: 16 }
            requires :product_ids, type: String, desc: 'Comma Separated Product ids', documentation: { example: '1234,2445,7865' }
          end

          get '/available_quantity' do
            retailer = Retailer.select(:id, :with_stock_level).find_by_id(params[:retailer_id])
            error!(CustomErrors.instance.retailer_not_found, 421) unless retailer
            product_ids = params[:product_ids].scan(/\d+/)
            error!(CustomErrors.instance.params_missing, 421) if product_ids.blank?
            shops = Shop.unscoped.where(retailer_id: params[:retailer_id], product_id: product_ids).select(:product_id, :available_for_sale, :is_available, :is_published)
            result = []
            shops.each { |shop| result << { product_id: shop.product_id, available_quantity: (retailer.with_stock_level ? shop.available_for_sale.to_i : -1), is_available: shop.is_available, is_published: shop.is_published } }
            result
          end
        end
      end
    end
  end
end

