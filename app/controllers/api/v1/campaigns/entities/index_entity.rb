module API
  module V1
    module Campaigns
      module Entities
        class IndexEntity < API::BaseEntity

          def self.entity_name
            'index_campaign'
          end

          expose :id, documentation: { type: 'Integer', desc: 'Id of campaign' }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: 'Name of campaign' }, format_with: :string
          expose :priority, documentation: { type: 'Integer', desc: 'Priority' }, format_with: :integer
          expose :campaign_type, documentation: { type: 'Integer', desc: 'Campaign Type' }, format_with: :integer
          expose :photo_url, as: :image_url, documentation: { type: 'String', desc: 'Photo Url' }, format_with: :string
          expose :banner_url, as: :banner_image_url, documentation: { type: 'String', desc: 'Banner Url' }, format_with: :string
          expose :web_photo_url, as: :web_image_url, documentation: { type: 'String', desc: 'Photo Url' }, format_with: :string, if: Proc.new { |obj| options[:web] }
          expose :web_banner_url, as: :web_banner_image_url, documentation: { type: 'String', desc: 'Banner Url' }, format_with: :string, if: Proc.new { |obj| options[:web] }
          expose :url, documentation: { type: 'String', desc: 'Url' }, format_with: :string
          expose :categories, documentation: { type: 'name_entity', desc: 'Categories' } do |result, options|
            API::V1::Categories::Entities::CategoryInProductEntity.represent object.c_categories, only: %i[id name slug]
          end
          expose :subcategories, documentation: { type: 'name_entity', desc: 'Subcategories' } do |result, options|
            API::V1::Categories::Entities::CategoryInProductEntity.represent object.c_subcategories, only: %i[id name slug]
          end
          expose :brands, merge: true, documentation: { type: 'name_entity', desc: 'Subcategories' } do |result, options|
            API::V1::Brands::Entities::ShowEntity.represent object.c_brands, except: %i[logo1_url logo2_url]
          end
          expose :retailer_ids, documentation: { type: 'Array', desc: 'Retailer ids' }
          expose :exclude_retailer_ids, documentation: { type: 'Array', desc: 'Exclude Retailer ids' }
          expose :locations, documentation: { type: 'Array', desc: 'locations' }
          expose :store_type_ids, as: :store_types, documentation: { type: 'Array', desc: 'Store Type ids' }
          expose :retailer_group_ids, as: :retailer_groups, documentation: { type: 'Array', desc: 'Retailer Group ids' }

        end
      end
    end
  end
end
