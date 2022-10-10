class AddDateTimeOffsetInShopperFacingTables < ActiveRecord::Migration[5.1]
  def change
    add_column :shoppers, :date_time_offset, :string
    add_column :shopper_addresses, :date_time_offset, :string
    add_column :shopper_recipes, :date_time_offset, :string
    add_column :shopper_agreements, :date_time_offset, :string
    add_column :shopper_cart_products, :date_time_offset, :string
    add_column :retailers, :date_time_offset, :string
    add_column :orders, :date_time_offset, :string
    add_column :order_positions, :date_time_offset, :string
    add_column :order_substitutions, :date_time_offset, :string
    add_column :order_collection_details, :date_time_offset, :string
    add_column :collector_details, :date_time_offset, :string
    add_column :promotion_code_realizations, :date_time_offset, :string
    add_column :analytics, :date_time_offset, :string
    add_column :events, :date_time_offset, :string
    add_column :credit_cards, :date_time_offset, :string
    add_column :order_feedbacks, :date_time_offset, :string
    add_column :vehicle_details, :date_time_offset, :string
    add_column :online_payment_logs, :date_time_offset, :string
  end
end
