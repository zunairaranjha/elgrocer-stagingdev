module API
  module V1
    module ProductProposals
      class Create < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :product_proposals do
          #   desc 'This API will create the promotion code'

          params do
            requires :oos_product_id, type: Integer, desc: 'OOS Product id', documentation: { example: 123407 }
            requires :barcode, type: String, desc: 'Product barcode', documentation: { example: '1234070216354' }
            requires :name, type: String, desc: 'Product name', documentation: { example: 'Kit Kat' }
            requires :size_unit, type: String, desc: 'Size of the Product', documentation: { example: '1kg' }
            requires :price, type: Float, desc: 'Price of the Product', documentation: { example: 100.0 }
            requires :order_id, type: Integer, desc: 'Order that is going to get substituted', documentation: { example: 1234567 }
            requires :retailer_id, type: Integer, desc: 'Retailer Id of that product', documentation: { example: 1234567 }
            requires :type_id, type: Integer, desc: 'why this product got added', documentation: { example: 1 }
            optional :product_id, type: Integer, desc: 'Product Id', documentation: { example: 1234567 }
            optional :promotional_price, type: Float, desc: 'Promotional Price of the Product', documentation: { example: 100.0 }
            optional :is_promotion_available, type: Boolean, desc: 'Is Promotion Available on the Product', documentation: { example: true }
            optional :shop_id, type: Integer, desc: 'Shop id of the product', documentation: { example: 1 }
            optional :description, type: String, desc: 'Description of the product', documentation: { example: 'Kit kat chocolate' }
            optional :photo, type: Rack::Multipart::UploadedFile, desc: 'Photo of Recipe'
          end

          post do
            error!(CustomErrors.instance.not_allowed) unless current_employee
            error!(CustomErrors.instance.params_missing, 421) if params[:product_id].blank? && params[:photo].blank?
            product_proposal = ProductProposal.transaction do
              product = find_create_product
              pp = create_update_product_proposals(product)
              add_image(pp, product)
              pp
            end
            present product_proposal, with: API::V1::ProductProposals::Entities::ShowEntity
          end
        end

        helpers do
          def find_create_product
            product = Product.unscoped.find_or_initialize_by(barcode: params[:barcode])
            return product if product.persisted?

            product.name = params[:name]
            product.size_unit = params[:size_unit]
            product.brand_id = product(params[:oos_product_id]).brand_id
            product.description = params[:description]
            product.save
            product
          end

          def create_update_product_proposals(prod)
            pr = ProductProposal.find_or_initialize_by(barcode: params[:barcode], order_id: params[:order_id], oos_product_id: params[:oos_product_id])
            pr.name = params[:name]
            pr.size_unit = params[:size_unit]
            pr.retailer_id = params[:retailer_id]
            pr.price = params[:price]
            pr.brand_id ||= prod&.brand_id
            pr[:details][:description] = params[:description]
            pr[:details][:shop_id] = params[:shop_id]
            if params[:is_promotion_available]
              pr.is_promotion_available = params[:is_promotion_available]
              pr.promotional_price = params[:promotional_price]
            end
            pr.subcategory_ids = categories(prod.id) if prod && !pr.persisted?
            pr.type_id = params[:type_id]
            pr.product_id = prod&.id
            pr.save
            pr
          end

          def add_image(product_proposal, product = nil)
            return unless params[:photo] || product.photo_file_size

            img = Image.find_or_initialize_by(record: product_proposal)
            if params[:photo]
              img.photo = ActionDispatch::Http::UploadedFile.new(params[:photo])
            elsif product&.photo
              img.photo = product.photo
            end
            img.save(validate: false)
          end

          def product(id = nil)
            @product ||= Product.unscoped.find_by_id(id)
          end

          def categories(product_id)
            ProductCategory.where(product_id: product_id).pluck(:category_id)
          end

        end
      end
    end
  end
end
