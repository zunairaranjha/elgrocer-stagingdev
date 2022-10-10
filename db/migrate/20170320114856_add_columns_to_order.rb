class AddColumnsToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :is_on_time, :boolean
    add_column :orders, :is_accurate, :boolean
    add_column :orders, :is_price_same, :boolean
    add_column :orders, :feedback_comments, :text
  end
end
