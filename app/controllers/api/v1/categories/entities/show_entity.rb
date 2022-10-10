module API
  module V1
    module Categories
      module Entities
        class ShowEntity < API::BaseEntity
          def self.entity_name
            'show_category'
          end
          expose :id, documentation: { type: 'Integer', desc: "ID of the category" }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: "Category name" }, format_with: :string
          expose :image_url, documentation: { type: 'String', desc: "An URL directing to a photo." }, format_with: :string
          expose :slug, documentation: { type: 'String', desc: 'Slug of the Category.' }, format_with: :string
        
          # private
        
          # def image_url
          #   object.photo.url
          # end
        end        
      end
    end
  end
end