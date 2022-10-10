# frozen_string_literal: true

ActiveAdmin.register CollectorDetail do
  menu parent: "Shoppers"
  includes :shopper
  actions :all, except: [:new,:edit,:destroy]
  index do
    column :name
    column :phone_number
    column :shopper
    column :is_deleted
    column :created_at
    column :updated_at
    actions
  end
  
  filter :name
  filter :phone_number
  filter :shopper_id , label: 'SHOPPER ID'
  filter :is_deleted
  filter :created_at
  filter :updated_at
  end
