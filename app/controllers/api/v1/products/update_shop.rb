# frozen_string_literal: true

module API
  module V1
    module Products
      class UpdateShop < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
        resource :products do
          desc "Changes fileds of the product's data. Requires authentication. Requires authentication."
          params do
            requires :product_id, type: Integer, desc: 'ID of the Shop product', documentation: { example: 16 }
            optional :is_published, type: Boolean, desc: 'published Products in my shop ', documentation: { example: false }
            optional :is_available, type: Boolean, desc: 'Disable Products only in my shop', documentation: { example: false }
          end
          put '/update_shop' do

            if current_employee
              retailer = current_employee.retailer || Retailer.find_by(id: params[:retailer_id]) unless (current_employee.active_roles & [4, 5]).blank?
            else
              retailer = current_retailer
            end

            error!(CustomErrors.instance.not_allowed, 421) unless retailer

            shop = Shop.unscoped.find_by(product_id: params[:product_id], retailer_id: retailer.id)
            if shop.present?
              target_user = current_employee || current_retailer
              detail = { 'owner_type' => target_user.class.name, 'owner_id' => target_user.id }
              # shop.update(is_available: params[:is_available]) unless params[:is_available].nil?
              # shop.update(is_published: params[:is_published]) unless params[:is_published].nil?
              # shop.owner_for_log = retailer
              unless (shop.detail['last_inactive_time'] && shop.detail['last_inactive_time'].to_time > (Time.now - 1.day).utc) || shop.detail['permanently_disabled'].to_i.positive?
                shop.is_published = params[:is_published] if params.has_key?(:is_published)
                shop.is_available = params[:is_available] if params.has_key?(:is_available)
                shop.detail.merge!(detail)
                shop.save rescue shop
              end
              present shop.product, with: API::V1::Products::Entities::ShowEntity, retailer: retailer
            else
              error!({ error_code: 403, error_message: 'Product does not exist' }, 403)
            end
          end
        end
      end
    end
  end
end
