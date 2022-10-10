class AddCancelingDataToOrder < ActiveRecord::Migration
  def up
    add_column :orders, :user_canceled_type, :integer
    add_column :orders, :canceled_at, :datetime
  end

  def down
    drop_column :orders, :user_canceled_type
    drop_column :orders, :canceled_at
  end
end
