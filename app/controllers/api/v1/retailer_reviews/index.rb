# frozen_string_literal: true

module API
  module V1
    module RetailerReviews
      class Index < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :retailer_reviews do
          desc "List of all reviews.", entity: API::V1::RetailerReviews::Entities::IndexEntity
          params do
            requires :retailer_id, type: Integer, desc: 'Retailer id', documentation: { example: 6 }
            requires :limit, type: Integer, desc: 'Limit of products', documentation: { example: 20 }
            requires :offset, type: Integer, desc: 'Offset of products', documentation: { example: 10 }
          end
          get do
            is_next = false
            retailer = Retailer.find_by(:id => params[:retailer_id])
            if retailer
              if params['limit'] + params['offset'] < retailer.retailer_reviews.order(:id).count
                is_next = true
              end
      
              reviews = retailer.retailer_reviews.limit(params[:limit]).offset(params[:offset])
              result = {is_next: is_next, reviews: reviews}
              present result, with: API::V1::RetailerReviews::Entities::IndexEntity
            else
              error!({error_code: 404, error_message: "Retailer does not exist!"},404)
            end
          end
        end
      end      
    end
  end
end