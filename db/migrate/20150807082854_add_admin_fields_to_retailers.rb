class AddAdminFieldsToRetailers < ActiveRecord::Migration
  def change
    add_column :retailers, :delivery_team_commitment, :integer
    add_column :retailers, :number_of_deliveries_per_hour_commitment, :integer
    [:store_owner_name, :store_owner_phone_number, :store_owner_email, 
    :store_manager_name, :store_manager_phone_number, :store_manager_email,
    :integration_level].each do |f|
      add_column :retailers, f, :string
    end
    add_column :retailers, :notes, :text
    add_column :retailers, :delivery_notes, :text

  end
end
