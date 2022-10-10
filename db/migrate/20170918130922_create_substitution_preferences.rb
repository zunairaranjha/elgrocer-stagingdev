class CreateSubstitutionPreferences < ActiveRecord::Migration
  def change
    create_table :substitution_preferences do |t|
      t.integer :category_id
      t.float :brand_priority
      t.float :size_priority
      t.float :price_priority
      t.float :flavour_priority
      t.integer :min_match
      t.integer :shopper_id
    end
  end
end
