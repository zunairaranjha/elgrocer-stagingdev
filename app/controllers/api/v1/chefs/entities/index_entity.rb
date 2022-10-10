module API
  module V1
    module Chefs
      module Entities
        class IndexEntity < API::BaseEntity
          def self.entity_name
            'index_chef'
          end
          expose :id, documentation: { type: 'Integer', desc: "ID of the chef" }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: "Chef name" }, format_with: :string
          expose :image_url, documentation: { type: 'String', desc: "An URL directing to a photo." }, format_with: :string
          expose :insta, documentation: { type: 'String', desc: "Chef's Instagram ID" }, format_with: :string
          expose :blog, documentation: { type: 'String', desc: "Chef's blog link" }, format_with: :string
          expose :slug, documentation: { type: 'String', desc: "Slug of chef" }, format_with: :string
          expose :description, documentation: { type: 'String', desc: "Description of chef" }, format_with: :string
          expose :seo_data, documentation: {type: 'String', desc: "SEO Data"}, format_with: :string, if: Proc.new { |obj| options[:web] }
        
          def image_url
            object.photo_url
          end
        end                
      end
    end
  end
end