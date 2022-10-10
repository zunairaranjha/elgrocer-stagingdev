# frozen_string_literal: true

module API
  module V1
    module Products
      class RemoveFromShop < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :products do
          desc "Add product to retailer's shop. Requires authentication."
          params do
          end
          route_param :product_id do
            delete '/remove_from_shop' do

              if current_employee
                retailer = current_employee.retailer || Retailer.find_by(id: params[:retailer_id]) unless (current_employee.active_roles & [4, 5]).blank?
              else
                retailer = current_retailer
              end

              error!(CustomErrors.instance.not_allowed, 421) unless retailer

              if request.headers['App-Version'].to_s.gsub('.', '').to_f > 251389.0
                product = Product.unscoped.find_by(id: params[:product_id])
                error!({ error_code: 403, error_message: 'Product not exists' }, 403) unless product
                product.remove_from_shop(retailer.id)
                status 200
                true
              else
                target_user = current_employee || current_retailer
                detail = { owner_type: target_user.class.name, owner_id: target_user.id }
                # shop = Shop.unscoped.find_by(product_id: params[:product_id], retailer_id: retailer.id)
                shop = Shop.unscoped.where(product_id: params[:product_id], retailer_id: retailer.id)
                error!({ error_code: 403, error_message: 'Product not exists' }, 403) unless shop.length.positive?
                # shop.update!(is_available: false)
                shop.update_all("is_available = false, updated_at= '#{Time.now}', detail = detail::jsonb || '#{detail.to_json}'::jsonb")
                status 200
                true
              end
            end
          end
        end
      end
    end
  end
end
