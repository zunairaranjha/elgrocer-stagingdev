# frozen_string_literal: true

module API
  module V3
    module Retailers
      module Entities
        class RetailerTypeEntity < API::BaseEntity
          root 'retailer_types', 'retailer_type'

          def self.entity_name
            'retailer_type'
          end

          expose :id, documentation: { type: 'Integer', desc: 'Id of retailer type' }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: 'Name' }, format_with: :string
          expose :description, documentation: { type: 'String', desc: 'Description' }, format_with: :string
          expose :priority, documentation: { type: 'Integer', desc: 'Priority' }, format_with: :integer
          expose :bg_color, documentation: { type: 'String', desc: 'Background color' }, format_with: :string
          expose :image_url, documentation: { type: 'String', desc: 'Image Url' }, format_with: :string

          def image_url
            object.image&.photo_url
          end
        end
      end
    end
  end
end
