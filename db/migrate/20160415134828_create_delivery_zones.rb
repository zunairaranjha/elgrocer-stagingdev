class CreateDeliveryZones < ActiveRecord::Migration
  def change
    create_table :delivery_zones do |t|
      t.string :name
      t.st_polygon :coordinates
      t.string :description
      t.string :color
      t.integer :width

      t.timestamps null: false
    end

    add_index :delivery_zones, :coordinates, using: :gist
  end
end
