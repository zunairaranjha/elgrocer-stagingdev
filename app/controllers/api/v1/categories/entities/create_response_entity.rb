module API
  module V1
    module Categories
      module Entities
        class ShowSubcategory < API::BaseEntity
          def self.entity_name
            'show_subcategory'
          end
          expose :id, documentation: { type: 'Integer', desc: "ID of the category" }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: "Category name" }, format_with: :string
          expose :image_url, documentation: { type: 'String', desc: "An URL directing to a photo." }, format_with: :string
        
          # private
        
          # def image_url
          #   object.photo.url
          # end
        end
        
        class CreateResponseEntity < API::BaseEntity
          def self.entity_name
            'show_new_category'
          end
          expose :id, documentation: { type: 'Integer', desc: "ID of the category" }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: "Category name" }, format_with: :string
          expose :image_url, documentation: { type: 'String', desc: "An URL directing to a photo." }, format_with: :string
          expose :subcategories, using: API::V1::Categories::Entities::ShowSubcategory, as: :children, documentation: {type: 'show_subcategory', is_array: true }
        
        
          private
        
          def subcategories
            object.subcategories
          end
        
          # def image_url
          #   object.photo.url
          # end
        end                
      end
    end
  end
end