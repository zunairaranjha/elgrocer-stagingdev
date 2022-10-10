module API
  module V1
    module Products
      class AddToShop < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :products do
          desc "Add product to retailer's shop. Requires authentication.", entity: API::V1::Products::Entities::ShowEntity
          params do
            requires :price_cents, type: Integer, desc: 'Product price in cents', documentation: { example: 20 }
            requires :price_dollars, type: Integer, desc: 'Product price in dollars', documentation: { example: 2 }
          end
          route_param :product_id do
            post '/add_to_shop' do

              if current_employee
                retailer = current_employee.retailer || Retailer.find_by(id: params[:retailer_id]) unless (current_employee.active_roles & [4, 5]).blank?
              else
                retailer = current_retailer
              end

              error!(CustomErrors.instance.not_allowed, 421) unless retailer

              product = Product.unscoped.find(params[:product_id])

              if product
                target_user = current_employee || current_retailer
                detail = { 'owner_type' => target_user.class.name, 'owner_id' => target_user.id }
                result = product.add_to_shop(retailer.id, params[:price_cents], params[:price_dollars], detail)

                #load price info
                product = Product.unscoped.includes(:brand, :subcategories, :categories)
                product = product.joins("left outer join shops on shops.product_id = products.id and shops.retailer_id = #{retailer.id}").select('products.*,shops.id shop_id,shops.price_currency,shops.price_dollars,shops.price_cents,shops.is_available,shops.is_published,shops.is_promotional,shops.retailer_id') if retailer
                product = product.find(params[:product_id])

                product = product || result

                present product, with: API::V1::Products::Entities::ShowEntity, retailer: retailer
              else
                error!({ error_code: 403, error_message: "Product not exists" }, 403)
              end
            end
          end
        end
      end
    end
  end
end