# frozen_string_literal: true

# class API::V1::Retailers::Entities::ShowBrands < API::BaseEntity
#   def self.entity_name
#     'retailer_brand'
#   end
#   expose :id, documentation: { type: 'Integer', desc: "ID of the category" }, format_with: :integer
#   expose :name, documentation: { type: 'String', desc: "Category name" }, format_with: :string
#   expose :image_url, documentation: {type: 'String', desc: "Image Url" }, format_with: :string
# end


# class API::V1::Retailers::Entities::ShowSubcategories< API::BaseEntity
#   def self.entity_name
#     'retailer_subcategorycategory'
#   end
#   expose :id, documentation: { type: 'Integer', desc: "ID of the category" }, format_with: :integer
#   expose :name, documentation: { type: 'String', desc: "Category name" }, format_with: :string
#   expose :brands, using: API::V1::Retailers::Entities::ShowBrands, documentation: {type: 'retailer_brand', is_array: true }
# end

# class API::V1::Retailers::Entities::ShowCategories< API::BaseEntity
#   def self.entity_name
#     'retailer_category'
#   end
#   expose :id, documentation: { type: 'Integer', desc: "ID of the category" }, format_with: :integer
#   expose :name, documentation: { type: 'String', desc: "Category name" }, format_with: :string
#   expose :children, using: API::V1::Retailers::Entities::ShowSubcategories, documentation: {type: 'retailer_subcategorycategory', is_array: true }
# end


module API
  module V1
    module Retailers
      module Entities
        class ElasticSearchEntity < API::BaseEntity
          root 'retailers', 'retailer'
        
          expose :id, documentation: { type: 'Integer', desc: 'ID of the retailer' }, format_with: :integer
          expose :company_name, documentation: { type: 'String', desc: 'Email retailer' }, format_with: :string
          expose :company_address, documentation: { type: 'String', desc: 'Shop name' }, format_with: :string
          expose :image_url, documentation: { type: 'String', desc: 'Phone number' }, format_with: :string
          expose :average_rating, documentation: { type: 'Float', desc: 'Shop average rating' }, format_with: :float
          # expose :categories, using: API::V1::Retailers::Entities::ShowCategories, documentation: {type: 'retailer_category', is_array: true }
        
          private
        
        end        
      end
    end
  end
end