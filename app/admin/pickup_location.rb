# frozen_string_literal: true

ActiveAdmin.register PickupLocation do
  menu parent: 'Retailers'
  includes :retailer
  permit_params :retailer_id, :details, :details_ar, :is_active, :photo, :lonlat, :created_at, :updated_at
  actions :all, except: [:destroy]

  filter :retailer_id, label: 'RETAILER ID'
  filter :details
  filter :details_ar
  filter :is_active
  filter :created_at
  filter :updated_at

  index pagination_total: false do
    column :retailer
    column :details
    column :details_ar
    column :is_active
    column :lonlat
    column :created_at
    column :updated_at
    actions
  end

  form do |f|
    f.inputs 'Pickup Locations' do
      f.input :retailer
      f.input :details
      f.input :details_ar
      f.input :photo, as: :file
      f.input :pickup_longitude, label: 'Longitude', as: :string
      f.input :pickup_latitude, label: 'Latitude', as: :string
      f.input :is_active
    end
    f.actions
  end

  show do
    attributes_table :retailer, :details, :details_ar, :is_active, :lonlat do
      row :photo do |p|
        image_tag(p.photo.url(:medium), :height => '50')
      end
    end
  end
  controller do
    def create
      lon = params[:pickup_location][:pickup_longitude]
      lat = params[:pickup_location][:pickup_latitude]
      params[:pickup_location][:lonlat] = "POINT (#{lon.to_f} #{lat.to_f})"

      super
    end

    def update
      lon = params[:pickup_location][:pickup_longitude]
      lat = params[:pickup_location][:pickup_latitude]
      params[:pickup_location][:lonlat] = "POINT (#{lon.to_f} #{lat.to_f})"

      super
    end
  end
end
