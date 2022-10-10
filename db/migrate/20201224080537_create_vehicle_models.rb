class CreateVehicleModels < ActiveRecord::Migration[4.2]
  def change
    create_table :vehicle_models do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
