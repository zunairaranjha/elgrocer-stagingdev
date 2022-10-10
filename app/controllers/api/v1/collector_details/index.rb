module API
  module V1
    module CollectorDetails
      class Index < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :collector_details do
          desc "Show all Collectors details"
          params do
            requires :limit, type: Integer, desc: 'Limit of orders', documentation: { example: 20 }
            requires :offset, type: Integer, desc: 'Offset of orders', documentation: { example: 10 }
            optional :collector_id, type: Integer, desc: 'Id of Collector', documentation: { example: 10} 
          end
      
          get '/all' do
            error!(CustomErrors.instance.unauthorized, 421) unless current_shopper
            result = CollectorDetail.where(shopper_id: current_shopper.id, is_deleted: false).limit(params[:limit]).offset(params[:offset])
            result = result.find_by(id: params[:collector_id])  if params[:collector_id]
            present result, with: API::V1::CollectorDetails::Entities::IndexEntity
          end
        end
      end      
    end
  end
end
