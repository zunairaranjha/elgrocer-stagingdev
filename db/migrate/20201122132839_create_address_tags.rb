class CreateAddressTags < ActiveRecord::Migration
  def change
    create_table :address_tags do |t|
      t.string :name
      t.string :name_ar
      t.integer :priority, default: 0

      t.timestamps null: false
    end

    add_column :shopper_addresses, :address_tag_id, :integer
  end
end
