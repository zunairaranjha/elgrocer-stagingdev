# frozen_string_literal: true

module API
  module V1
    module Products
      module Entities
        class ShowChildren < API::BaseEntity
          def self.entity_name
            'show_children'
          end
          expose :id, documentation: { type: 'Integer', desc: "ID of the category" }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: "Category name" }, format_with: :string
          expose :image_url, documentation: { type: 'String', desc: "An URL directing to a photo." }, format_with: :string
          expose :slug, documentation: { type: 'String', desc: 'Slug of the Category.' }, format_with: :string
          expose :is_show_brand, documentation: { type: 'Boolean', desc: 'Is show brand in Apps' }, format_with: :bool
          expose :is_food, documentation: { type: 'Boolean', desc: 'Is show brand in Apps' }, format_with: :bool
          expose :pg_18, documentation: { type: 'Boolean', desc: 'Is show brand in Apps' }, format_with: :bool
        
        end
        
        
        class ShowCategoryEntity < API::BaseEntity
          def self.entity_name
            'show_category'
          end
          expose :id, documentation: { type: 'Integer', desc: "ID of the category" }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: "Category name" }, format_with: :string
          expose :image_url, documentation: { type: 'String', desc: "An URL directing to a photo." }, format_with: :string
          expose :slug, documentation: { type: 'String', desc: 'Slug of the Category.' }, format_with: :string
          expose :is_show_brand, documentation: { type: 'Boolean', desc: 'Is show brand in Apps' }, format_with: :bool
          expose :is_food, documentation: { type: 'Boolean', desc: 'Is show brand in Apps' }, format_with: :bool
          expose :pg_18, documentation: { type: 'Boolean', desc: 'Is show brand in Apps' }, format_with: :bool
          expose :children, using: API::V1::Products::Entities::ShowChildren, documentation: {type: 'pro_name', is_array: true }
          # expose :subcategories, as: :children, using: API::V1::Products::Entities::ShowNameEntity, documentation: {type: 'pro_name', is_array: true }
        
          # private
          # def image_url
          #   object[:image_url]
          # end
        end        
      end
    end
  end
end