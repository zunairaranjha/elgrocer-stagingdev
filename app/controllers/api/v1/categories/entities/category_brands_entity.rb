# frozen_string_literal: true

module API
    module V1
      module Categories
        module Entities
            class CategoryBrandsEntity < API::BaseEntity
                expose :brands, using: API::V1::Brands::Entities::ShowEntity, documentation: {type: 'show_brand', is_array: true }
            end          
        end
      end
    end
  end