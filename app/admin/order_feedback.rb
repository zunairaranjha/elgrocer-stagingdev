# frozen_string_literal: true

ActiveAdmin.register OrderFeedback do
  menu parent: 'Orders'
  actions :all, except: %i[new edit destroy]
  includes :retailer, :picker, order: [:shopper]
  # actions :index, :show
  # permit_params :order_id,:delivery,:speed,:accuracy,:price,:comments,:created_at,:updated_at

  # remove_filter :order
  filter :order_retailer_id_eq, label: 'Retailer ID'
  filter :retailer_company_name_cont, as: :string, label: 'Retailer Name'
  filter :order_shopper_id_eq, label: 'Shopper ID'
  filter :order_picker_id_eq, label: 'Picker ID'
  filter :picker_name_cont, as: :string, label: 'Picker Name'
  filter :order_id
  filter :delivery
  filter :speed
  filter :accuracy
  filter :price
  filter :comments
  filter :created_at
  filter :updated_at

  index do
    column :order
    column :retailer
    column :shopper
    column :picker
    column :delivery_stars
    column :speed do |of|
      of.order&.retailer_service_id.to_i == 2 ? OrderFeedback.accuracies.key(OrderFeedback.speeds[of.speed]) : of.speed
    end
    column :accuracy
    column :price
    column :comments
    column :created_at
    actions
  end

  remove_filter :order

  show do
    attributes_table do
      row :order
      row :delivery
      row :speed do |of|
        of.order&.retailer_service_id.to_i == 2 ? OrderFeedback.accuracies.key(OrderFeedback.speeds[of.speed]) : of.speed
      end
      row :accuracy
      row :price
      row :comments
      row :time_zone, &:date_time_offset
      row :created_at
      row :updated_at
    end
  end

  csv do
    column :order_id
    column 'Retailer Id' do |of|
      of.retailer.id rescue ''
    end
    column 'Retailer Name' do |of|
      of.retailer.company_name rescue ''
    end
    column 'Shopper Id' do |of|
      of.shopper.id rescue ''
    end
    column 'Shopper Name' do |of|
      of.shopper.name rescue ''
    end
    column 'Picker ID' do |of|
      of.picker.id rescue ''
    end
    column 'Picker Name' do |of|
      of.picker.name rescue ''
    end
    column :delivery_stars
    column :speed
    column :accuracy
    column :price
    column :comments
    column :created_at
  end
end
