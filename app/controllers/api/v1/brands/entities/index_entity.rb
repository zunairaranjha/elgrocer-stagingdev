

module API
  module V1
    module Brands
      module Entities
        class IndexEntity < API::BaseEntity
          expose :next, documentation: { type: 'Bool', desc: "Is something else in list of brands?" }, format_with: :bool
          expose :brands, using: API::V1::Brands::Entities::ShowEntity, documentation: {type: 'show_brand', is_array: true }
        end        
      end
    end
  end
end