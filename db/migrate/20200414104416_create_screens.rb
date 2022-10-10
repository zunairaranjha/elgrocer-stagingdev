class CreateScreens < ActiveRecord::Migration
  def change
    create_table :screens do |t|
      t.string :name
      t.integer :priority
      t.integer :group
      t.boolean :is_active, default: true
      t.attachment :photo
      t.attachment :photo_ar

      t.timestamps null: false
    end
  end
end
