# frozen_string_literal: true

module API
  module V1
    module PromotionCodes
      module Entities
        class PromoCodeBrandsEntity < API::BaseEntity
          expose :id, documentation: { type: 'Integer', desc: 'ID of the brand' }, format_with: :integer
          expose :name, documentation: { type: 'Integer', desc: 'name of the brand' }, format_with: :string
        end
      end
    end
  end
end
