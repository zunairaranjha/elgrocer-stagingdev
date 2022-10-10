class AddPlatformTypeToOrder < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :platform_type, :integer
  end
end
