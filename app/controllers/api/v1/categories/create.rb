# frozen_string_literal: true

module API
  module V1
    module Categories
      class Create < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :categories do
          desc "Allows creating of a category. Requires authentication.", entity: API::V1::Categories::Entities::CreateResponseEntity
          params do
            optional :category_id, type: Integer, desc: "Category_id", documentation: { example: 5 }
            requires :category_name, type: String, desc: "Category name", documentation: { example: "Food" }
            requires :subcategory_name, type: String, desc: "Subcategory name", documentation: { example: "GoodFoof" }
          end
          post do

            if current_employee
              retailer = current_employee.retailer || Retailer.find_by(id: params[:retailer_id]) unless (current_employee.active_roles & [4, 5]).blank?
            else
              retailer = current_retailer
            end

            error!(CustomErrors.instance.not_allowed, 421) unless retailer

            result = ::Categories::Create.run(params)
            if result.valid?
              category = Category.find_by(id: result.result.id)
              present category, with: API::V1::Categories::Entities::CreateResponseEntity
            else
              error!({ error_code: 403, error_message: result.errors }, 403)
            end
          end
        end
      end
    end
  end
end