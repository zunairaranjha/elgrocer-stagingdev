# frozen_string_literal: true

module API
  module V1
    module RetailerReviews
      module Entities
        class ShowEntity< API::BaseEntity
          def self.entity_name
            'show_review'
          end
          expose :id, documentation: { type: 'Integer', desc: "ID of the category" }, format_with: :integer
          expose :average_rating, documentation: { type: 'Float', desc: "Avarage rating" }, format_with: :float
          expose :comment, documentation: { type: 'String', desc: "Comment added to a review"}, format_with: :string
          expose :shopper_name, documentation: { type: 'String', desc: "Shopper's name"}, format_with: :string
          expose :created_at, documentation: { type: 'String', desc: "Review creation date"}, format_with: :string
        
          private
        
          def shopper_name
            shopper = Shopper.find_by(:id => object.shopper_id)
            if shopper
              shopper.name
            else
              'User removed'
            end
          end
        
          def average_rating
            object.average_rating
          end
        
        end                
      end
    end
  end
end