# frozen_string_literal: true

module API
  module V1
    module Products
      module Entities
        class UpdateImageEntity < API::BaseEntity
          root 'products', 'product'
        
          expose :id, documentation: { type: 'Integer', desc: 'ID of the product' }, format_with: :integer
          expose :image_url, documentation: { type: 'String', desc: "An URL directing to a photo of the product." }, format_with: :string
          expose :full_image_url, documentation: { type: 'String', desc: "An URL directing to a photo of the product." }, format_with: :string
        
          private
          def image_url
            object.photo.url(:medium)
          end
        
          def full_image_url
            object.photo.url
          end
        end                
      end
    end
  end
end