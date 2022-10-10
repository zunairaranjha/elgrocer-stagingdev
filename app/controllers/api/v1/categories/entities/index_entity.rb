module API
  module V1
    module Categories
      module Entities
        class IndexEntity < API::BaseEntity
          expose :non_empty_categories, using: API::V1::Categories::Entities::ShowEntity, as: :categories, documentation: {type: 'show_category', is_array: true }
          expose :next, documentation: { type: 'Boolean', desc: "Is something else in list of categories?" }, format_with: :bool
        
          def non_empty_categories
            result = []
            object[:categories].each do |cat|
              result.push(cat) if cat.subcategory_brands.size > 0
            end
            result
          end
        end                
      end
    end
  end
end