class CreateScreenRetailers < ActiveRecord::Migration
  def change
    create_table :screen_retailers, id: false do |t|
      t.integer :screen_id
      t.integer :retailer_id
    end
  end
end
