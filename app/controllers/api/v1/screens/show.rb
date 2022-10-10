module API
  module V1
    module Screens
      class Show < Grape::API
        # include TokenAuthenticable
        version 'v1', using: :path
        format :json

        resource :screens do
          desc "List of all the custom screens for a retailer", entity: API::V1::Screens::Entities::IndexEntity
          params do
            optional :retailer_ids, type: String, desc: 'List Of Retailer Ids', documentation: { example: "16,178,201" }
            optional :locations, type: String, desc: 'Tier of screen', documentation: { example: "1,2" }
            optional :store_type_ids, type: String, desc: 'Store Type of screen', documentation: { example: "1,3" }
            optional :retailer_group_ids, type: String, desc: 'Retailer Group Ids', documentation: { example: "72,1" }
            optional :date_filter, type: Boolean, desc: 'Consider Date Filter', documentation: { example: false }
          end

          get '/show' do
            # screens = Screen.distinct.joins("LEFT JOIN screen_retailers ON screens.id = screen_retailers.screen_id")
            screens = Screen.where(is_active: true)
            screens = screens.where("? between date(start_date) and date(end_date)", Time.now.to_date) if params[:date_filter]
            screens = screens.where("'{#{params[:locations]}}'::INT[] && locations") if params[:locations].present?
            # screens = screens.joins("LEFT JOIN retailers ON retailers.retailer_group_id = ANY(screens.retailer_groups)")
            # screens = screens.where("(screen_retailers.retailer_id IN (#{params[:retailer_ids]}) OR  retailers.id IN (#{params[:retailer_ids]}))") if params[:retailer_ids]
            # if params[:retailer_ids]
            #   screens = screens.where("screen_retailers.retailer_id IN (#{params[:retailer_ids].to_s}) OR '{#{params[:store_type_ids]}}'::INT[] && store_types OR '{#{params[:retailer_group_ids]}}'::INT[] && retailer_groups")
            # else
            screens = screens.where("'{#{params[:retailer_ids]}}'::INT[] && retailer_ids OR'{#{params[:store_type_ids]}}'::INT[] && store_types OR '{#{params[:retailer_group_ids]}}'::INT[] && retailer_groups")
            # end
            # screens = screens.where("'{#{params[:store_type_ids]}}'::INT[] && store_types") if params[:store_type_ids].present?
            # screens = screens.where("'{#{params[:retailer_group_ids]}}'::INT[] && retailer_groups") if params[:retailer_group_ids].present?
            # screens = screens.select("screens.*, ARRAY_AGG(distinct screen_retailers.retailer_id) AS screen_store_ids")
            screens = screens.group("screens.id")
            screens = screens.order(:group, :priority).order(:id)
            present screens, with: API::V1::Screens::Entities::IndexEntity
          end
        end
      end
    end
  end
end