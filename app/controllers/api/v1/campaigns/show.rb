module API
  module V1
    module Campaigns
      class Show < Grape::API
        version 'v1', using: :path
        format :json

        resource :campaigns do
          desc 'To get Campaigns'

          params do
            requires :campaign_id, type: Integer, desc: 'Campaign Id', documentation: { example: 1 }
          end

          get '/show' do
            campaigns = Campaign.includes(:c_brands, :c_categories, :c_subcategories)
            campaigns = campaigns.where('? BETWEEN start_time AND end_time', Time.now.utc)
            campaigns = campaigns.where(id: params[:campaign_id]).first
            error!(CustomErrors.instance.campaign_not_found, 421) unless campaigns
            present campaigns, with: API::V1::Campaigns::Entities::IndexEntity, web: request.headers['Referer']
          end
        end
      end
    end
  end
end
