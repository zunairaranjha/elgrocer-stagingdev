# frozen_string_literal: true

module API
  module V2
    module Categories
      module Entities
        class CategoryBrandsEntity < API::BaseEntity
          # this will return brands and 6 products based on category_id
          # Date: 7 October 2016
          expose :brands, using: API::V1::Brands::Entities::ShowBrandWithProductEntity, documentation: {type: 'show_brand', is_array: true }
          expose :next, documentation: { type: 'Boolean', desc: "Is something else in list of categories?" }, format_with: :bool
        end        
      end
    end
  end
end