# frozen_string_literal: true

module API
  module V2
    module Recipes
      module Entities
        class ShowEntity < API::V1::Recipes::Entities::ShowEntity

          def self.entity_name
            'show_recipe'
          end

          unexpose :recipe_category_id
          unexpose :recipe_category_name
          unexpose :chef_id
          unexpose :is_published
          unexpose :cooking_steps
          expose :priority, documentation: { type: 'Integer', desc: 'Priority' }, format_with: :integer
          expose :storyly_slug, documentation: { type: 'String', desc: 'Storyly Slug' }, format_with: :string
          expose :images, documentation: {type: 'images', is_array: true }
          expose :is_saved, documentation: { type: 'Boolean', desc: 'Saved for Shopper or Not' }, format_with: :bool
          expose :retailer_ids, documentation: { type: 'Array', desc: 'Retailer ids' }
          expose :store_type_ids, as: :store_types, documentation: { type: 'Array', desc: 'Store Type ids' }
          expose :retailer_group_ids, as: :retailer_groups, documentation: { type: 'Array', desc: 'Retailer Group ids' }
          expose :exclude_retailer_ids, documentation: { type: 'Array', desc: 'Exclude retailer ids' }
          expose :ingredients, override: true, using: API::V2::Recipes::Entities::IngredientsEntity, documentation: {type: 'show_recipe_ingredients', is_array: true }
          expose :categories, using: API::V2::Recipes::Entities::CategoryEntity, documentation: {type: 'recipe_category', is_array: true }
          expose :cooking_steps, override: true, using: API::V2::Recipes::Entities::CookingStepEntity, documentation: {type: 'show_cooking_steps', is_array: true }

          private

          def images
            images_urls = []
            object.images.order(:priority).each do |img|
              images_urls.push(img.photo_url)
            end
            images_urls
          end

          def is_saved
            !object.try(:shopper_id).blank?
          end

          def categories
            object.recipe_categories
          end

          # def ingredients
          #   object.ingredients.joins("left outer join shops on shops.product_id = ingredients.product_id and shops.retailer_id = #{options[:retailer_id].to_i}").includes(product: [:categories, :subcategories, :brand])
          #         .select("ingredients.*,shops.price_dollars,shops.price_cents,shops.is_available,shops.is_published,shops.is_promotional")
          # end

        end
      end
    end
  end
end
