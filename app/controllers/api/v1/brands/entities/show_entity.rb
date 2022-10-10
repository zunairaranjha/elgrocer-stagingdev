module API
  module V1
    module Brands
      module Entities
        class ShowEntity < API::BaseEntity
          root 'brands', 'brand'

          def self.entity_name
            'show_brand'
          end

          expose :id, documentation: { type: 'Integer', desc: 'ID of the brand' }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: 'Name of the brand' }, format_with: :string
          expose :photo_url, as: :image_url, documentation: { type: 'String', desc: 'An URL directing to a photo.' }, format_with: :string
          expose :logo1_url, documentation: { type: 'String', desc: 'Logo 1 photo url.' }, format_with: :string
          expose :logo2_url, documentation: { type: 'String', desc: 'Logo 2 photo url.' }, format_with: :string
          expose :slug, documentation: { type: 'String', desc: 'URL friendly name' }, format_with: :string
          expose :seo_data, documentation: { type: 'String', desc: 'SEO Data' }, format_with: :string, if: Proc.new { |obj| options[:web] }

          private

          # def image_url
          #   object.photo.url
          # end
        end
      end
    end
  end
end
