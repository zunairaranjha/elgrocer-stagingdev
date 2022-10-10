
module API
  module V1
    module Banners
      module Entities
        class BannerLinkEntity < API::BaseEntity
          root 'banner_links', 'banner_link'
        
          def self.entity_name
            'show_banner_links'
          end
        
          expose :id, documentation: { type: 'Integer', desc: "ID of the brand" }, format_with: :integer
          expose :category_id, documentation: { type: 'Integer', desc: "Category ID" }, format_with: :integer
          expose :category, using: API::V2::Categories::Entities::ShowEntity
          expose :subcategory_id, documentation: { type: 'Integer', desc: "Sub-Category ID" }, format_with: :integer
          expose :subcategory, using: API::V2::Categories::Entities::ShowEntity
          expose :brand_id, documentation: { type: 'Integer', desc: "Brand ID" }, format_with: :integer
          expose :brand, using: API::V1::Brands::Entities::ShowEntity
          expose :priority, documentation: { type: 'Integer', desc: "Priority ID" }, format_with: :integer
          expose :photo_url, documentation: { type: 'String', desc: "Photo url." }, format_with: :string
        
        end                
      end
    end
  end
end