class AddLanguageToShopper < ActiveRecord::Migration
  def change
    add_column :shoppers,:language,:integer,default: 0
  end
end
