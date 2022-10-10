module API
  module V2
    module Retailers
      module Entities
        class ShowCategoryEntity < API::BaseEntity

          expose :id, documentation: { type: 'Integer', desc: "ID of the category" }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: "Category name" }, format_with: :string
          expose :slug, documentation: { type: 'String', desc: "URL friendly name" }, format_with: :string
          expose :image_url, documentation: { type: 'String', desc: "An URL directing to a photo." }, format_with: :string
          expose :children, documentation: {type: 'subcategory', is_array: true }do |result, options|
            API::V1::Categories::Entities::ShowEntity.represent get_subcategory
          end
        
          def image_url
            object.photo.url(:medium)
          end
        
          def get_subcategory
            Product.find(options[:product_id]).subcategories
          end
        end        
      end
    end
  end
end