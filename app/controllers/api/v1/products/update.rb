module API
  module V1
    module Products
      class Update < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :products do
          desc "Changes fileds of the product's data. Requires authentication. Requires authentication.", entity: API::V1::Products::Entities::ShowEntity
          params do
            requires :product_id, type: Integer, desc: "ID of the product", documentation: { example: 16 }
            optional :name, type: String, desc: "Product name", documentation: { example: 'Coca Cola Light' }
            optional :description, type: String, desc: "Product description", documentation: { example: 'low-calorie (0.3 kcal per 100ml) variation of Coca-Cola specifically marketed' }
            optional :barcode, type: String, desc: "Product barcode", documentation: { example: '7894900011593' }
            optional :size_unit, type: String, desc: "Product size", documentation: { example: '250 ml' }
            # requires :shelf_life, type: Integer, desc: "Product shelf life in weeks", documentation: { example: 4 }
            optional :shelf_life, type: Integer, desc: "Product shelf life in weeks", documentation: { example: 4 }
            optional :brand_name, type: String, desc: "Product brand", documentation: { example: 'Coca Cola' }
            # requires :country_alpha2, type: String, desc: "Product made in location", documentation: { example: 'US' }
            optional :country_alpha2, type: String, desc: "Product made in location", documentation: { example: 'US' }
            optional :is_local, type: Boolean, desc: "Value bool eq true if product is in local base", documentation: { example: true }
            optional :subcategory_id, type: Integer, desc: "Subcategory_id", documentation: { example: 5 }
            # optional :categories, type: Array, desc: "List of categories product", documentation: { example: {name: 'Energy Drink', parent: {name: 'Drink'}} }
          end
          put '/update' do

            if current_employee
              retailer = current_employee.retailer || Retailer.find_by(id: params[:retailer_id]) unless (current_employee.active_roles & [4, 5]).blank?
            else
              retailer = current_retailer
            end

            error!(CustomErrors.instance.not_allowed, 421) unless retailer

            # comment these to Start API function
            product = Product.unscoped.find_by({id: params[:product_id]})
            error!({ error_code: 403, error_message: "Product does not exist" }, 403) unless product
            present product, with: API::V1::Products::Entities::ShowEntity, retailer: retailer

            # uncomment these to Start API function
            # result = ::Products::Update.run(params)
            # if result.valid?
            #   present result.result, with: API::V1::Products::Entities::ShowEntity, retailer: retailer
            # else
            #   error!({ error_code: 403, error_message: "Product does not exist" }, 403)
            # end
          end
        end
      end
    end
  end
end