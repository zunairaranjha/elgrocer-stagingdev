class AddLanguageToOrders < ActiveRecord::Migration
  def change
    add_column :orders,:language,:integer,default: 0
  end
end
