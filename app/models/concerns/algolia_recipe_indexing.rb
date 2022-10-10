module AlgoliaRecipeIndexing
  extend ActiveSupport::Concern

  included do
    include AlgoliaSearch

    after_touch :index!

    algoliasearch index_name: "RecipeBoutique", if: :is_published do
      attribute :id, :name, :is_published, :slug, :retailer_ids, :retailer_group_ids, :store_type_ids, :exclude_retailer_ids
      attribute :image_url do
        photo_url
      end
      attribute :name_ar do
        name_ar
      end
      # attribute :category_id do recipe_category_id end
      # attribute :category_name do recipe_category.name end
      attribute :categories do
        recipe_categories.map do |category|
          {
            id: category.id,
            name: category.name,
            slug: category.slug,
            image_url: category.photo_url,
            name_ar: category.name_ar
          }
        end
      end
      attribute :chef do
        {
          id: chef.id,
          name: chef.name,
          name_ar: chef.name_ar,
          slug: chef.slug,
          image_url: chef.photo_url
        }
      end
      attribute :ingredients do
        # ingredient_id = ingredients.map { |i| i.id }
        ingredient_and_product = Ingredient.where("ingredients.recipe_id = #{id}").joins("INNER JOIN products ON products.id = ingredients.product_id").select("ingredients.id, products.name AS product_name, products.name_ar AS product_name_ar")
        ingredient_and_product.map do |ingredient|
          {
            id: ingredient.id,
            name: ingredient.product_name,
            name_ar: ingredient.product_name_ar
          }
        end
      end

    end
  end
end