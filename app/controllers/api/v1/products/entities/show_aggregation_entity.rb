# frozen_string_literal: true

module API
  module V1
    module Products
      module Entities
        class ShowAggregationEntity < API::BaseEntity
          root 'aggregations', 'aggregation'
          def self.entity_name
            'show_aggregation'
          end
          expose :aggs, documentation: { desc: "es aggregations" }
          expose :categories, using: API::V2::Categories::Entities::ShowEntity
          expose :subcategories, using: API::V2::Categories::Entities::ShowEntity
          expose :brands, using: API::V1::Brands::Entities::ShowEntity
        end                
      end
    end
  end
end