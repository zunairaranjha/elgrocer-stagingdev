class AddFeedbackStatusToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :feedback_status, :integer, default: 0
    remove_column :orders, :is_on_time
    remove_column :orders, :is_accurate
    remove_column :orders, :is_price_same
    remove_column :orders, :feedback_comments
  end
end
