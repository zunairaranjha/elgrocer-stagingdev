# frozen_string_literal: true

ActiveAdmin.register Location do
  menu parent: "Collections"
  includes :primary_location
  permit_params :name, :city_id, :active, :primary_location_id, :slug, :seo_data
  # actions :all
  # actions :index, :show

  remove_filter :shopper_addresses
  remove_filter :slugs
  remove_filter :retailers
  remove_filter :retailer_has_locations

  controller do
    def scoped_collection
      super.includes :city, :primary_location
    end
  end

  index do
    # sortable_tree_columns
    column :name
    column :city
    column :primary_location
    column :slug
    column :active
    actions
  end

  form html: {enctype: "multipart/form-data"} do |f|
    f.inputs "Basic details" do
      f.input :name
      f.input :city
      f.input :primary_location
      f.input :slug
      f.input :active
      f.input :seo_data
    end
    f.actions
  end

  # show do
  #   attributes_table do
  #     default_attribute_table_rows.each do |field|
  #       row field
  #     end

  #     # Custom bits here

  #   end
  # end
end
