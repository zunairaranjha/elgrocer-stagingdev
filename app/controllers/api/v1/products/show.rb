# frozen_string_literal: true

module API
  module V1
    module Products
      class Show < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :products do
          desc "Find product by barcode in base. Requires authentication.", entity: API::V1::Products::Entities::ShowEntity
          params do
            requires :barcode, type: String, desc: 'Products barcode', documentation: { example: '7894900011593' }
          end
          route_param :barcode do
            get do

              if current_employee
                retailer = current_employee.retailer || Retailer.find_by(id: params[:retailer_id])
              else
                retailer = current_retailer
              end

              error!(CustomErrors.instance.not_allowed, 421) unless retailer

              result = ::Products::Show.run(barcode: params[:barcode])
              if result.valid?
                present result.result, with: API::V1::Products::Entities::ShowEntity, retailer: retailer
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