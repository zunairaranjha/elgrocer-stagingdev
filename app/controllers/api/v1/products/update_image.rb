# frozen_string_literal: true

module API
  module V1
    module Products
      class UpdateImage < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :products do
          desc "Update photo of the product. Requires authentication.", entity: API::V1::Products::Entities::UpdateImageEntity
          params do
            requires :image, type: Rack::Multipart::UploadedFile, desc: "Photo shop"
          end
          route_param :product_id do
            post '/update_image' do
              if current_employee
                retailer = current_employee.retailer || Retailer.find_by(id: params[:retailer_id]) unless (current_employee.active_roles & [4, 5]).blank?
              else
                retailer = current_retailer
              end

              error!(CustomErrors.instance.not_allowed, 421) unless retailer

              product = Product.unscoped.find_by({ id: params[:product_id] })
              if product
                if params[:image]
                  product.photo = ActionDispatch::Http::UploadedFile.new(params[:image])
                  product.save
                  present product, with: API::V1::Products::Entities::UpdateImageEntity
                else
                  error!({ error_code: 403, error_message: "Empty photo" }, 403)
                end
              else
                error!({ error_code: 403, error_message: "Product does not exist" }, 403)
              end
            end
          end
        end
      end
    end
  end
end