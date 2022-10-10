# frozen_string_literal: true

module API
  module V1
    module Categories
      class Categories < Grape::API
        include TokenAuthenticable
        helpers API::V1::Concerns::SharedParams
        version 'v1', using: :path
        format :json

        resource :categories do
          desc "List of all product's categories. Requires authentication.", entity: API::V1::Categories::Entities::IndexForRetailerEntity
          params do
            use :categories_tree
          end

          get '/tree' do

            if current_employee
              retailer = current_employee.retailer || Retailer.find_by(id: params[:retailer_id])
            else
              retailer = current_retailer
            end

            error!(CustomErrors.instance.not_allowed, 421) unless retailer

            params.tap do |p|
              p.merge!(retailer_id: retailer.id) if retailer.present?
            end
            result = ::CategoriesEndpointService.result(params)
            present result, with: API::V1::Categories::Entities::IndexForRetailerEntity
          end
        end
      end
    end
  end
end