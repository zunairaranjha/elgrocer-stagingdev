class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
      t.string :name
      t.attachment :photo
      t.integer :recipe_category_id
      t.integer :prep_time
      t.integer :cook_time
      t.string :description
      t.integer :chef_id
      t.integer :for_people
      t.boolean :is_published

      t.timestamps
    end
  end
end
