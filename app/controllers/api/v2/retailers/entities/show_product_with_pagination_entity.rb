# frozen_string_literal: true

module API
  module V2
    module Retailers
      module Entities
        class ShowProductWithPaginationEntity < API::BaseEntity
          expose :next, documentation: { type: 'Bool', desc: "Is something else in list of products?" }, format_with: :bool
          expose :products, documentation: {type: 'show_product', is_array: true }do |result, options|
            if result[:only_retailer]
              API::V1::Products::Entities::ElasticSearchEntity.represent result[:products], options.merge(retailer: Retailer.find(options[:retailer_id]))
            else
              API::V2::Retailers::Entities::ShowProductEntity.represent result[:products], options.merge(retailer_id: options[:retailer_id])
            end
          end
        end
                
      end
    end
  end
end