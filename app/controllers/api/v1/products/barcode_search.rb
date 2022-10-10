module API
  module V1
    module Products
      class BarcodeSearch < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :products do
          desc 'This api is to scan product through barcode'

          params do
            requires :barcode, type: String, desc: 'Products barcode', documentation: { example: '1234070216354' }
            requires :retailer_id, type: Integer, desc: 'Retailer Id', documentation: { example: 32 }
            optional :shop_price, type: Float, desc: 'Shop Price', documentation: { example: '12.33' }
            optional :is_catalogue_search, type: Boolean, desc: 'Is Catalogue Search', documentation: { example: 32 }
          end

          get '/barcode_search' do
            error!(CustomErrors.instance.not_allowed) unless current_employee

            retailer = current_employee.retailer || Retailer.find_by(id: params[:retailer_id])
            error!(CustomErrors.instance.retailer_not_found, 421) unless retailer

            product = Product.find_by(barcode: params[:barcode])
            error!(CustomErrors.instance.product_missing, 421) unless product

            shop = Shop.unscoped.where(retailer_id: retailer.id, product_id: product.id).first

            unless params[:is_catalogue_search]
              if shop.blank? && params[:shop_price].present?
                shop = Shop.new(retailer_id: retailer.id, product_id: product.id, is_available: true, is_published: true)
                shop.price_dollars = params[:shop_price].to_i
                shop.price_cents = ((params[:shop_price].to_f - params[:shop_price].to_i) * 100)
                shop.save
              elsif !shop.blank?
                if params[:shop_price].present?
                  shop.price_dollars = params[:shop_price].to_i
                  shop.price_cents = ((params[:shop_price] * 100) % 100).round
                end
                unless shop.is_available && shop.is_published
                  shop.is_available = true
                  shop.is_published = true
                end
                shop.save if shop.changed?
              end
            end

            API::V1::Products::Entities::BarcodeSearchEntity.represent product, root: false, retailer: retailer, shop: shop
          end
        end
      end
    end
  end
end
