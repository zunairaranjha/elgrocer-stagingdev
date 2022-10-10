module API
  module V1
    module Screens
      class Index < Grape::API
        # include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :screens do
          desc "List of all the custom screens for a retailer", entity: API::V1::Screens::Entities::IndexEntity
          params do
            optional :id, type: Integer, desc: "Screen Id", documentation: { example: 3 }
            optional :retailer_id, type: Integer, desc: "Retailer id/slug", documentation: { example: "16,178,201" }
            optional :locations, type: String, desc: 'Tier of screen', documentation: { example: "3" }
            optional :store_type_ids, type: String, desc: 'Store Type of screen', documentation: { example: "1,3" }
            optional :retailer_group_ids, type: String, desc: 'Retailer Group Ids', documentation: { example: "72,1" }
            optional :date_filter, type: Boolean, desc: 'Consider Date Filter', documentation: { example: false }
          end

          get do
            # retailer = params[:retailer_id][/\p{L}/] ? Retailer.find_by(slug: params[:retailer_id]) : Retailer.find_by(id: params[:retailer_id]) if params[:retailer_id]
            # if retailer
            # screens = Screen.joins("LEFT JOIN screen_retailers ON screens.id = screen_retailers.screen_id")
            # screens = Screen.joins("LEFT JOIN retailers ON retailers.retailer_group_id = ANY(screens.retailer_groups)")
            # screens = screens.where("screens.is_active = 't' AND (screen_retailers.retailer_id = #{retailer.id} OR retailers.id = #{retailer.id})")
            # screens = Screen.joins("LEFT JOIN retailers ON retailers.retailer_group_id = ANY(screens.retailer_groups)")
            screens = Screen.where(is_active: true)
            screens = screens.where("? between date(start_date) and date(end_date)", Time.now.to_date) if params[:date_filter]
            screens = screens.where("'{#{params[:locations]}}'::INT[] && locations") if params[:locations].present?
            screens = screens.where(id: params[:id]) if params[:id].present?
            screens = screens.where("'{#{params[:retailer_id]}}'::INT[] && retailer_ids OR'{#{params[:store_type_ids]}}'::INT[] && store_types OR '{#{params[:retailer_group_ids]}}'::INT[] && retailer_groups") unless params[:id].present?
            # screens = screens.where("screens.is_active = 't' AND '{#{params[:store_type_ids]}}'::INT[] && store_types OR '{#{params[:retailer_group_ids]}}'::INT[] && retailer_groups")  unless params[:retailer_id]
            screens = screens.order(:group, :priority).order(:id)
            present screens.distinct, with: API::V1::Screens::Entities::IndexEntity
            # else
            # error!({error_code: 401, error_message: "Retailer not found"},401)
            # end
          end
        end
      end
    end
  end
end