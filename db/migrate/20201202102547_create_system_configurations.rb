class CreateSystemConfigurations < ActiveRecord::Migration
  def change
    create_table :system_configurations do |t|
      t.string :key
      t.string :value

      t.timestamps null: false
    end
  end
end
