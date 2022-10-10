class AddDataToOrderPositions < ActiveRecord::Migration
  def up
    add_column :orders, :retailer_phone_number, :string
    add_column :orders, :retailer_company_name, :string
    add_column :orders, :retailer_opening_time, :string
    add_column :orders, :retailer_company_address, :string
    add_column :orders, :retailer_phone_contact_email, :string
    add_column :orders, :retailer_delivery_range, :string

    add_column :order_positions, :product_barcode, :string
    add_column :order_positions, :product_brand_name, :string
    add_column :order_positions, :product_name, :string
    add_column :order_positions, :product_description, :string
    add_column :order_positions, :product_shelf_life, :integer
    add_column :order_positions, :product_size_unit, :string
    add_column :order_positions, :product_country_alpha2, :string
    add_column :order_positions, :product_location_id, :integer
    add_column :order_positions, :product_category_name, :string
    add_column :order_positions, :product_subcategory_name, :string
  end
  def down
    drop_column :orders, :retailer_phone_number
    drop_column :orders, :retailer_company_name
    drop_column :orders, :retailer_opening_time
    drop_column :orders, :retailer_company_dropress
    drop_column :orders, :retailer_phone_contact_email
    drop_column :orders, :retailer_delivery_range

    drop_column :order_positions, :product_barcode
    drop_column :order_positions, :product_brand_name
    drop_column :order_positions, :product_name
    drop_column :order_positions, :product_description
    drop_column :order_positions, :product_shelf_life
    drop_column :order_positions, :product_size_unit
    drop_column :order_positions, :product_country_alpha2
    drop_column :order_positions, :product_location_id
    drop_column :order_positions, :product_category_name
    drop_column :order_positions, :product_subcategory_name
  end
end