# frozen_string_literal: true

module API
  module V1
    module Products
      module Entities
        class ShowEsBrandEntity < API::BaseEntity
          root 'brands', 'brand'
        
          def self.entity_name
            'show_es_brand'
          end
        
          expose :id, documentation: { type: 'Integer', desc: "ID of the brand" }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: "Name of the brand" }, format_with: :string
          expose :image_url, documentation: { type: 'String', desc: "An URL directing to a photo." }, format_with: :string
        
          private
        end                
      end
    end
  end
end