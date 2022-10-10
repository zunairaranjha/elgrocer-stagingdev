# frozen_string_literal: true

module API
  module V1
    module Categories
      module Entities
        class ShowCategory < API::BaseEntity
          def self.entity_name
            'show_cache_category'
          end
          expose :id, documentation: { type: 'Integer', desc: "ID of the category" }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: "Category name" }, format_with: :string
          expose :image_url, documentation: { type: 'String', desc: "An URL directing to a photo." }, format_with: :string
          expose :subcategories, using: API::V1::Categories::Entities::ShowEntity, as: :children, documentation: {type: 'show_category', is_array: true }
        
          private
        
          def subcategories
            object.subcategories
          end
        
          # def image_url
          #   object.photo.url
          # end
        
        end
        
        class IndexForRetailerCacheEntity < API::BaseEntity
          expose :categories, using: API::V1::Categories::Entities::ShowCategory, documentation: {type: 'show_cache_category', is_array: true }
          expose :next, documentation: { type: 'Boolean', desc: "Is something else in list of categories?" }, format_with: :bool
        
        end                
      end
    end
  end
end