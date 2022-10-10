# frozen_string_literal: true

module API
  module V1
    module Categories
      class Index < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :categories do
          desc "List of all product's categories. Requires authentication.", entity: API::V1::Categories::Entities::IndexEntity
          params do
            requires :limit, type: Integer, desc: 'Limit of categories', documentation: { example: 20 }
            requires :offset, type: Integer, desc: 'Offset of categories', documentation: { example: 10 }
          end
          get do
            is_next = false

            if current_employee
              retailer = current_employee.retailer || Retailer.find_by(id: params[:retailer_id])
            else
              retailer = current_retailer
            end

            error!(CustomErrors.instance.not_allowed, 421) unless retailer

            if retailer || current_employee
              if params['limit'] + params['offset'] < Category.includes(:subcategories).where(parent_id: nil).order(:name).count
                is_next = true
              end
              result = { :next => is_next, categories: Category.includes(:subcategories).where(parent_id: nil).order(:name).limit(params['limit']).offset(params['offset']) }
              present result, with: API::V1::Categories::Entities::IndexForRetailerCacheEntity
            else
              if params['limit'] + params['offset'] < Category.includes(:subcategories).includes(:brands).where(parent_id: nil).order(:name).count
                is_next = true
              end
              result = { :next => is_next, categories: Category.includes(:subcategories).includes(:brands).where(parent_id: nil).order(:name).limit(params['limit']).offset(params['offset']) }
              present result, with: API::V1::Categories::Entities::IndexForShopperEntity
            end
          end
        end
      end
    end
  end
end