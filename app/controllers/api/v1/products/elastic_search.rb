# frozen_string_literal: true

module API
  module V1
    module Products
      class ElasticSearch < Grape::API
        # include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :products do
          desc "Find product by provided input. Requires authentication.", entity: API::V1::Products::Entities::ElasticSearchEntity
          params do
            requires :search_input, type: String, desc: 'Search input', documentation: { example: 'CocaCola' }
            requires :page, type: Integer, desc: "Page number", documentation: { example: 2 }
          end
      
          post '/elastic_search' do
            error!({ error_code: 10_422, error_message: 'Please update to latest version' }, 422)
            #if current_retailer
            #  result = Product.search_name(true, params[:search_input]).page(params[:page])
            #  present result, with: API::V1::Products::Entities::ElasticSearchEntity #, retailer: current_retailer
            #end
          end
        end
      end
      
    end
  end
end