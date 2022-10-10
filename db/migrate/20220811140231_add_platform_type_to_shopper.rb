class AddPlatformTypeToShopper < ActiveRecord::Migration[5.1]
  def change
    add_column :shoppers, :platform_type, :integer
  end
end
