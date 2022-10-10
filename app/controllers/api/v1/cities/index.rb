module API
  module V1
    module Cities
      class Index < Grape::API
        version 'v1', using: :path
        format :json
      
        resource :cities do
          desc "List of all Cities.", entity: API::V1::Cities::Entities::ShowEntity
          params do
            optional :limit, type: Integer, desc: 'Limit', documentation: { example: 20 }
            optional :offset, type: Integer, desc: 'Offset', documentation: { example: 10 }
            optional :retailer_id, desc: 'retailer_id', documentation: { example: 10 }
          end
          get '' do
            result = City.order(:id).limit(params[:limit]).offset(params[:offset])
            result = result.joins({locations: :retailers}).where('retailer_id = ?', Retailer.find(params[:retailer_id])).distinct if params[:retailer_id].present?
            present result, with: API::V1::Cities::Entities::ShowEntity
          end
        end
      end      
    end
  end
end