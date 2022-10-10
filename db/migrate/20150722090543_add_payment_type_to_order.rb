class AddPaymentTypeToOrder < ActiveRecord::Migration
  def up
    add_column :orders, :payment_type_id, :integer

  end
  def down
    remove_column :orders, :payment_type_id, :integer

  end
end
