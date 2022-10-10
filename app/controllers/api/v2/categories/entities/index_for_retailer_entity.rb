# frozen_string_literal: true

module API
  module V2
    module Categories
      module Entities
        class ShowCategory< API::BaseEntity
          def self.entity_name
            'show_category'
          end
          expose :id, documentation: { type: 'Integer', desc: "ID of the category" }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: "Category name" }, format_with: :string
          expose :slug, documentation: { type: 'String', desc: "URL friendly name" }, format_with: :string
          expose :image_url, documentation: { type: 'String', desc: "An URL directing to a photo." }, format_with: :string
        
          def image_url
            object.logo.present? ? object.logo.url(:medium) : "http://#{options[:env]['HTTP_HOST']}"+ object.logo.url(:medium)
          end
        
          private
        end
        
        class IndexForRetailerEntity < API::BaseEntity
          expose :categories, using: API::V2::Categories::Entities::ShowCategory, as: :categories, documentation: {type: 'show_category', is_array: true }
          expose :next, documentation: { type: 'Boolean', desc: "Is something else in list of categories?" }, format_with: :bool
        end
                        
      end
    end
  end
end