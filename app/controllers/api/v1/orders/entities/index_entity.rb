module API
  module V1
    module Orders
      module Entities
        class IndexEntity < API::BaseEntity
          expose :orders, using: API::V1::Orders::Entities::ShowEntity, documentation: {type: 'show_order', is_array: true}
        end                
      end
    end
  end
end