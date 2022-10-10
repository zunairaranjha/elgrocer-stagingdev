class CreateCookingSteps < ActiveRecord::Migration
  def change
    create_table :cooking_steps do |t|
      t.integer :recipe_id
      t.integer :step_number
      t.string :step_detail
      t.integer :time
      t.attachment :photo
      
      t.timestamps
    end
  end
end
