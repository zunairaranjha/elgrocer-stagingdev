# frozen_string_literal: true

ActiveAdmin.register ShopProductLog do
  menu parent: "Products"
  # actions :index
  actions :all, except: [:new, :edit, :destroy]
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  filter :id
  filter :product_id
  filter :category_id
  filter :retailer_id
  filter :subcategory_id
  filter :brand_id
  filter :retailer_name
  filter :product_name
  filter :category_name
  filter :brand_name
  filter :subcategory_name
  filter :is_published
  filter :is_available
  filter :owner_type
  filter :owner_id, label: "Owner Id"
  filter :created_at
  filter :updated_at

  # filter :retailer_company_name
  # filter :created_at, label: I18n.t(:date, :scope => ["activerecord", "labels", "order"])
  #
  index pagination_total: false do
    column :id
    column :retailer_id
    column :retailer_name
    column :product_id
    column :product_name
    column :category_id
    column :category_name
    column :subcategory_id
    column :subcategory_name
    column :brand_id
    column :brand_name
    column :price
    column :is_available
    column :is_published
    column :owner_id
    column :owner_type
    column :created_at
  end

end
