module API
  module V1
    module Banners
      module Entities
        class ShowEntity < API::BaseEntity
          root 'banners', 'banner'
        
          def self.entity_name
            'show_banner'
          end
        
          expose :id, documentation: { type: 'Integer', desc: "ID of the brand" }, format_with: :integer
          expose :title, documentation: { type: 'String', desc: "Title" }, format_with: :string
          expose :title_ar, documentation: { type: 'String', desc: "Title" }, format_with: :string
          expose :subtitle, documentation: { type: 'String', desc: "Subtitle" }, format_with: :string
          expose :subtitle_ar, documentation: { type: 'String', desc: "Subtitle" }, format_with: :string
          expose :desc, documentation: { type: 'String', desc: "Description EN" }, format_with: :string
          expose :desc_ar, documentation: { type: 'String', desc: "Description AR" }, format_with: :string
          expose :btn_text, documentation: { type: 'String', desc: "Button Text EN" }, format_with: :string
          expose :btn_text_ar, documentation: { type: 'String', desc: "Button Text AR" }, format_with: :string
          expose :color, documentation: { type: 'String', desc: "Color" }, format_with: :string
          expose :text_color, documentation: { type: 'String', desc: "Text Color" }, format_with: :string
          # expose :category_id, documentation: { type: 'Integer', desc: "Category ID" }, format_with: :integer
          # expose :subcategory_id, documentation: { type: 'Integer', desc: "Sub-Category ID" }, format_with: :integer
          # expose :brand_id, documentation: { type: 'Integer', desc: "Brand ID" }, format_with: :integer
          expose :group, documentation: { type: 'Integer', desc: "Banners Group ID" }, format_with: :integer
          expose :priority, documentation: { type: 'Integer', desc: "Priority ID" }, format_with: :integer
          # expose :photo_url, documentation: { type: 'String', desc: "Photo url." }, format_with: :string
          # expose :preferences, documentation: { desc: "Settings for this banner", is_array: true } #, format_with: :string
          expose :banner_links, using: API::V1::Banners::Entities::BannerLinkEntity, documentation: { desc: "Links for this banner", is_array: true }
          expose :retailer_ids, documentation: { type: 'store_ids', desc: "Retailer ids", is_array: true }
        
          private
        
          def retailer_ids
            object.try("banner_store_ids")
          end
        
        end                
      end
    end
  end
end