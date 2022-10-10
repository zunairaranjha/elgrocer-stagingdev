class RecipesCategory < ApplicationRecord
  belongs_to :recipe, optional: true
  belongs_to :recipe_category, optional: true
end