# frozen_string_literal: true

module API
  module V1
    module Products
      module Entities
        class ShowNameEntity < API::BaseEntity
          def self.entity_name
            'name_entity'
          end

          expose :id, documentation: { type: 'Integer', desc: 'ID' }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: 'Name' }, format_with: :string
          expose :image_url, documentation: { type: 'String', desc: 'An URL directing to a photo.' }, format_with: :string
          expose :slug, documentation: { type: 'String', desc: 'Slug of the Category.' }, format_with: :string
          expose :show_brand, as: :is_show_brand, documentation: { type: 'Boolean', desc: 'Is show brand in Apps' }, format_with: :bool
          expose :is_food, documentation: { type: 'Boolean', desc: 'Is show brand in Apps' }, format_with: :bool
          expose :pg_18, documentation: { type: 'Boolean', desc: 'Is show brand in Apps' }, format_with: :bool

          def show_brand
            object.current_tags.include? Category.tags[:is_show_brand]
          end

          def is_food
            object.current_tags.include? Category.tags[:is_food]
          end

          def pg_18
            object.current_tags.include? Category.tags[:pg_18]
          end

          # private
          # def image_url
          #   object[:image_url]
          # end
        end
      end
    end
  end
end
