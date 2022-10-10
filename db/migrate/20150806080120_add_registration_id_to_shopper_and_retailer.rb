class AddRegistrationIdToShopperAndRetailer < ActiveRecord::Migration

  def up
    add_column :shoppers, :registration_id, :string
    add_column :shoppers, :device_type, :integer
    add_column :retailers, :registration_id, :string
    add_column :retailers, :device_type, :integer
  end

  def down
    remove_column :shoppers, :registration_id
    remove_column :shoppers, :device_type

    remove_column :retailers, :registration_id
    remove_column :retailers, :device_type
  end
end
