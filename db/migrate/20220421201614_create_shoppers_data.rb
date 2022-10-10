class CreateShoppersData < ActiveRecord::Migration[5.1]
  def change
    create_table :shoppers_data do |t|
      t.integer :shopper_id
      t.jsonb :detail, default: {}

      t.timestamps
    end
  end
end
