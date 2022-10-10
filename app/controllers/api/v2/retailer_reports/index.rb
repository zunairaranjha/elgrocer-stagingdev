# frozen_string_literal: true

module API
  module V2
    module RetailerReports
      class Index < Grape::API
        include TokenAuthenticable
        version 'v2', using: :path
        format :json
      
        resource :retailer_reports do
          desc "List of all retailer reports.", entity: API::V2::RetailerReports::Entities::IndexEntity
          params do
            optional :limit, type: Integer, desc: 'Limit of retailer reports', documentation: { example: 20 }
            optional :offset, type: Integer, desc: 'Offset of retailer reports', documentation: { example: 10 }
            #requires :shopper_id, type: Integer, desc: 'Shopper id, So it will return correct is_favourite', documentation: { example: 20 }
          end
      
          get do
            result = current_retailer.retailer_reports.order(created_at: :desc).take(10)
      
            #@is_next = retailers.size > params[:limit] + params[:offset]
      
            #.limit(params[:limit])
            #.offset(params[:offset])
            
            #retailers = retailers.sort_by{|e| e[:is_opened?] ? 1 : 0 }.reverse
            
            #result = {is_next: @is_next, reports: retailers}
            present result, with: API::V2::RetailerReports::Entities::IndexEntity
          end
        end
      end
    end
  end
end