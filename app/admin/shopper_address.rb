# frozen_string_literal: true

ActiveAdmin.register ShopperAddress do
  menu parent: "Shoppers"
  actions :all, except: [:new, :destroy]
  includes :shopper, :location, :address_tag

  permit_params :building_name, :street_address, :street, :street_number, :lonlat, :location_address
  # actions :index, :show

  remove_filter :shopper
  remove_filter :location

  show do
    attributes_table do
      default_attribute_table_rows.each do |field|
        row field
      end

      # Custom bits here

    end
  end

  form html: { enctype: "multipart/form-data" } do |f|
    f.inputs 'Edit Shopper Address' do
      f.input :building_name
      f.input :street_address
      f.input :street_number
      f.input :street
      f.input :longitude
      f.input :latitude
      f.input :location_address

    end
    f.actions
  end

  controller do

    def update
      params[:shopper_address][:lonlat] = "POINT (#{params[:shopper_address][:longitude]} #{params[:shopper_address][:latitude]})"

      super
    end

  end
end
