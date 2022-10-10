# frozen_string_literal: true

module API
  module V1
    module ProductProposals
      module Entities
        class ShowEntity < API::BaseEntity
          expose :id, documentation: { type: 'Integer', desc: 'Product Proposal id' }, format_with: :integer
          expose :order_id, documentation: { type: 'Integer', desc: 'Order id' }, format_with: :integer
          expose :name, documentation: { type: 'String', desc: 'Product name' }, format_with: :string
          expose :size_unit, documentation: { type: 'String', desc: 'Product size unit' }, format_with: :string
          expose :created_at, documentation: { type: 'String', desc: 'Products Suggestion creation date' }, format_with: :string
          expose :retailer_id, documentation: { type: 'Integer', desc: 'Retailer id' }, format_with: :integer
          expose :type_id, documentation: { type: 'Integer', desc: 'product addition type' }, format_with: :integer
          expose :order_id, documentation: { type: 'Integer', desc: 'Order id' }, format_with: :integer
          expose :barcode, documentation: { type: 'String', desc: 'Product barcode' }, format_with: :string
          expose :product_id, as: :oos_product_id, documentation: { type: 'Integer', desc: 'Order id' }, format_with: :integer
          expose :price, as: :full_price, documentation: { type: 'Float', desc: 'Order id' }, format_with: :float
          expose :price_currency, documentation: { type: 'String', desc: 'Price Currency' }, format_with: :string
          expose :promotional_price, documentation: { type: 'Float', desc: 'Order id' }, format_with: :float
          expose :is_promotion_available, documentation: { type: 'Boolean', desc: 'Order id' }, format_with: :bool
          expose :is_proposal_product, documentation: { type: 'Boolean', desc: 'Proposal Product id' }, format_with: :bool
          expose :order_id, documentation: { type: 'Integer', desc: 'Order id' }, format_with: :integer
          expose :categories_hash, using: API::V1::Products::Entities::ShowCategoryEntity, as: :categories, documentation: { type: 'show_category', is_array: true }
          expose :brand, using: API::V1::Brands::Entities::ShowEntity
          expose :image_url, documentation: { type: 'String', desc: 'Image URL of image' }, format_with: :string

          private

          def description
            object.details['description']
          end

          def categories_hash
            object.categories.map do |cat|
              result = {
                id: cat.id,
                name: cat.name,
                name_ar: cat.name_ar,
                image_url: cat.photo_url,
                is_show_brand: cat.current_tags.include?(Category.tags[:is_show_brand]),
                is_food: cat.current_tags.include?(Category.tags[:is_food]),
                pg_18: cat.current_tags.include?(Category.tags[:pg_18])
              }

              result[:children] = object.subcategories.map do |child|
                {
                  id: child.id,
                  name: child.name,
                  name_ar: child.name_ar,
                  image_url: child.photo_url,
                  is_show_brand: child.current_tags.include?(Category.tags[:is_show_brand]),
                  is_food: child.current_tags.include?(Category.tags[:is_food]),
                  pg_18: child.current_tags.include?(Category.tags[:pg_18])
                }
              end
              result
            end
          end

          def image_url
            Image.find_by(record: object)&.photo_url
          end

          def is_proposal_product
            true
          end

        end
      end
    end
  end
end
