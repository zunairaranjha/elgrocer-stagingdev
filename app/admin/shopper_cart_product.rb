# frozen_string_literal: true

ActiveAdmin.register ShopperCartProduct do
  menu parent: 'Shoppers'
  includes :shopper, :product, :retailer

  permit_params :shopper_id, :retailer_id, :product_id, :quantity

  actions :all # , except: [:new,:edit,:destroy]
  # actions :index, :show

  filter :shopper_id, label: 'shopper_id'
  filter :retailer_id, label: 'retailer_id'
  filter :retailer_company_name_cont, as: :string
  filter :product_id, label: 'product_id'
  filter :product_name_cont, as: :string
  filter :quantity
  filter :created_at
  filter :updated_at

  index do
    column :product
    column :quantity
    column :shopper_id
    column :retailer_id
    column :created_at
    column :updated_at
    actions
  end

  # show do
  #   attributes_table do
  #     default_attribute_table_rows.each do |field|
  #       row field
  #     end
  #   end
  # end
end
