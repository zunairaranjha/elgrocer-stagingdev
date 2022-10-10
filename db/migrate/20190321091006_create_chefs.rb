class CreateChefs < ActiveRecord::Migration
  def change
    create_table :chefs do |t|
      t.string :name
      t.attachment :photo
      t.string :insta
      t.string :blog

      t.timestamps
    end
  end
end
