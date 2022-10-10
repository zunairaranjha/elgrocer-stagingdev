# frozen_string_literal: true

module API
  module V2
    module Orders
      module Entities
        class IndexEntity < API::BaseEntity

          expose :orders, using: API::V2::Orders::Entities::ShowEntity, documentation: {type: 'show_order', is_array: true}
        end        
      end
    end
  end
end