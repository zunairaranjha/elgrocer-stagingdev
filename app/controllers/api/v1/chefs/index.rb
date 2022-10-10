module API
  module V1
    module Chefs
      class Index < Grape::API
        # include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :chefs do
          desc "return Chefs.", entity: API::V1::Chefs::Entities::IndexEntity
          params do
            optional :id, desc: 'ID of Chef', documentation: {example: 10}
            optional :limit, type: Integer, desc: 'Limit of Chefs', documentation: { example: 20 }
            optional :offset, type: Integer, desc: 'Offset of Chefs', documentation: { example: 10 }
          end
          get do
            chefs = Rails.cache.fetch([params,__method__], expires_in: 15.minutes) do
              if params[:id]
                chefs = Chef.find(params[:id])
              elsif request.headers['Authentication-Token'].to_s.eql?("36ninzmkhxHhWhxC8K8F")
                chefs = Chef.order("RANDOM()")#.limit(params[:limit]).offset(params[:offset])
              else
                chefs = Chef.joins(:recipes).where(recipes: {is_published: true}).select("chefs.*").group("chefs.id").order("RANDOM()")#.limit(params[:limit]).offset(params[:offset])
              end
              chefs.to_a
            end
            present chefs, with: API::V1::Chefs::Entities::IndexEntity, web: request.headers['Referer']
          end
        end
      end      
    end
  end
end