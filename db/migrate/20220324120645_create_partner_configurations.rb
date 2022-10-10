class CreatePartnerConfigurations < ActiveRecord::Migration[5.1]
  def change
    create_table :partner_configurations do |t|
      t.string :key
      t.string :fields
      t.timestamps
    end
  end
end
