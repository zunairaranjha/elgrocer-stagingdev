class CreateRetailerServices < ActiveRecord::Migration[4.2]
  def change
    create_table :retailer_services do |t|
      t.string :name
      t.float :search_radius
      t.float :availability_radius

      t.timestamps null: false
    end
  end
end
