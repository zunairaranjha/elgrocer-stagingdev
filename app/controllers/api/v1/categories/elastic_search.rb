# frozen_string_literal: true

module API
  module V1
    module Categories
      class ElasticSearch < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :categories do
          desc "Find product by provided input. Requires authentication.", entity: API::V1::Categories::Entities::ShowCategory
          params do
            optional :category_id, type: String, desc: 'Id of a category', documentation: { example: '1' }
            # requires :page, type: Integer, desc: "Page number", documentation: {example: 2}
          end
          post '/elastic_search' do
            error!({ error_code: 10_422, error_message: 'Please update to latest version' }, 422)
            #if params[:category_id]
            #  result = Category.search(
            #      {
            #        bool: {
            #          must: [
            #            {:term => {:id => params[:category_id]}}
            #          ]
            #        }
            #      }
            #  )
            #else
            #  result = Category.search(
            #      {
            #
            #      }
            #  )
            #end
            ## .page(params[:page])
            #result
          end      
        end
      end
    end
  end
end