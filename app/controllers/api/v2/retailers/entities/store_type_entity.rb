# frozen_string_literal: true

module API
  module V2
    module Retailers
      module Entities
        class StoreTypeEntity < API::BaseEntity
          root 'store_types', 'store_type'

          def self.entity_name
            'show_store_type'
          end

          expose :id, documentation: { type: 'Integer', desc: 'ID of Store Type' }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: 'Name of Store Type.' }, format_with: :string
          expose :priority, documentation: { type: 'Integer', desc: 'Priority of Store Type.' }, format_with: :integer
          expose :bg_color, documentation: { type: 'String', desc: 'Background Color' }, format_with: :string
          expose :photo_url, as: :image_url, documentation: { type: 'String', desc: 'An URL directing to a photo of the store_type.' }, format_with: :string

          private

          def photo_url
            options[:colored_logo] ? object.colored_image_url : object.image_url
          end

        end
      end
    end
  end
end
