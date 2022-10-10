# frozen_string_literal: true

module API
  module V1
    module RetailerReviews
      class Create < Grape::API
        include TokenAuthenticable
        version 'v1', using: :path
        format :json
      
        resource :retailer_reviews do
          desc "Allows creation of a review.", entity: API::V1::RetailerReviews::Entities::ShowEntity
          params do
            requires :retailer_id, type: Integer, desc: 'Retailer id', documentation: { example: 6 }
            requires :comment, type: String, desc: 'Comment content', documentation: { example: "Overall not bad but he misses the quality."}
            requires :overall_rating, type: Integer, desc: 'Overall rating of a retailer', documentation: { example: 4}
            requires :delivery_speed_rating, type: Integer, desc: 'Delivery speed rating of a retailer', documentation: { example: 3}
            requires :order_accuracy_rating, type: Integer, desc: 'Order accuracy rating of a retailer', documentation: { example: 5}
            requires :quality_rating, type: Integer, desc: 'Quality rating of a retailer', documentation: { example: 2}
            requires :price_rating, type: Integer, desc: 'Price rating of a retailer', documentation: { example: 4}
          end
          post do
            unless current_shopper.nil?
              result = ::RetailerReviews::CreateReview.run(params.merge(shopper_id: current_shopper.id))
              if result.valid?
                present result.result, with: API::V1::RetailerReviews::Entities::ShowEntity
              else
                r_err = result.errors
                error_code = 410
                if r_err['has_review'].present?
                  error_code = 423
                elsif r_err['no_retailer'].present?
                  error_code = 410
                end
                error!({ error_code: error_code, error_message: result.errors }, error_code)
              end
            else
              error!({ error_code: 403, error_message: "Only shoppers can review retailers!" }, 403)
            end
          end
        end
      end      
    end
  end
end