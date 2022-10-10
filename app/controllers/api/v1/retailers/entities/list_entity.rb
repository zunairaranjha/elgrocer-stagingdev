# frozen_string_literal: true

module API
  module V1
    module Retailers
      module Entities
        class ListEntity < API::BaseEntity
          root 'retailers', 'retailer'

          def self.entity_name
            'list_retailer'
          end

          expose :id, documentation: { type: 'Integer', desc: 'Id of the retailer' }, format_with: :integer
          expose :company_name, as: :name, documentation: { type: 'String', desc: 'Name of the retailer' }, format_with: :string
          expose :slug, documentation: { type: 'String', desc: 'Slug of the retailer' }, format_with: :string
          expose :photo_url, documentation: { type: 'String', desc: 'An URL directing to a photo of the shop.' }, format_with: :string

          private

          def photo_url
            object.photo.url(:medium)
          end

        end
      end
    end
  end
end
