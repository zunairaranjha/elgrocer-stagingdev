module API
  module V1
    module Brands
      class New < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :brands do
          desc "Create new brand. Requires authentication.", entity: API::V1::Brands::Entities::ShowEntity
          params do
            requires :name, type: String, desc: 'Brand name', documentation: { example: 'Nestle' }
          end
          post do
            if current_employee
              retailer = current_employee.retailer || Retailer.find_by(id: params[:retailer_id]) unless (current_employee.active_roles & [4, 5]).blank?
            else
              retailer = current_retailer
            end

            error!(CustomErrors.instance.not_allowed, 421) unless retailer

            result = Brand.find_by({ name: params[:name] })
            if not result
              result = Brand.create({ name: params['name'] })
            end
            present result, with: API::V1::Brands::Entities::ShowEntity
          end
        end
      end
    end
  end
end