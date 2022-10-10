# frozen_string_literal: true

ActiveAdmin.register VehicleDetail do
  menu parent: "Shoppers"
  includes :shopper, :color, :vehicle_model
  actions :all, except: [:new,:edit,:destroy]
  filter :plate_number
  filter :vehicle_model_id
  filter :color_id
  filter :company
  filter :shopper_id , label: 'SHOPPER ID'
  filter :collector_id , label: 'COLLECTOR ID'
  filter :is_deleted
  filter :created_at
  filter :updated_at

end

