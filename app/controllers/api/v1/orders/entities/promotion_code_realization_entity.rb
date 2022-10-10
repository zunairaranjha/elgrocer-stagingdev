module API
  module V1
    module Orders
      module Entities
        class PromotionCodeRealizationEntity < API::BaseEntity
          root 'promotion_code_realizations', 'promotion_code_realization'
        
          def self.entity_name
            'show_promotion_code_realization'
          end
        
          # expose :promotion_code, using: API::V1::Orders::Entities::PromotionCodeEntity,
          #   documentation: { type: 'show_promotion_code' }
          expose :promotion_code, documentation: { type: 'show_promotion_code', desc: "It'll show promotion code detail" } do |result, options|
            API::V1::Orders::Entities::PromotionCodeEntity.represent object.promotion_code, options.merge(discount_value: object.discount_value)
          end
        end
                
      end
    end
  end
end