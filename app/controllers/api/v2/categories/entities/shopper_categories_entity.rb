# frozen_string_literal: true

module API
  module V2
    module Categories
      module Entities
        class ShopperCategoriesEntity < API::BaseEntity
          expose :categories, using: API::V2::Categories::Entities::ShowEntity, documentation: {type: 'show_category', is_array: true }
          expose :next, documentation: { type: 'Boolean', desc: "Is something else in list of categories?" }, format_with: :bool
        end        
      end
    end
  end
end