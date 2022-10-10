class CreateColors < ActiveRecord::Migration[4.2]
  def change
    create_table :colors do |t|
      t.string :name
      t.string :name_ar
      t.string :color_code
      
      t.timestamps null: false
    end
  end
end
