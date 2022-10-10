class CreatePermissions < ActiveRecord::Migration[5.1]
  def change
    create_table :permissions do |t|
      t.string :name
      t.string :conditions
      t.timestamps
    end
  end
end
