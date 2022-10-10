# frozen_string_literal: true

module API
  module V1
    module Retailers
      class ElasticSearch < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :retailers do
          desc "Find retailer by provided id. Requires authentication.", entity: API::V1::Retailers::Entities::ElasticSearchEntity
          params do
      
            requires :retailer_id, type: Integer, desc: "Retailer id", documentation: {example: 2}
          end
          post '/elastic_search' do
            error!({ error_code: 10_422, error_message: 'Please update to latest version' }, 422)
            #result = Retailer.search(
            #    {
            #      bool: {
            #        must: [
            #          {:term => {:id => params[:retailer_id]}},
            #          {:term => {:is_active => true}},
            #          {:term => {:is_opened => true}}
            #        ]
            #      }
            #    }
            #)
            #result
          end
      
        end
      end
    end
  end
end