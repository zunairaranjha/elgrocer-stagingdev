# frozen_string_literal: true

ActiveAdmin.register RetailerGroup do
  menu parent: 'Retailers'
  permit_params :name
  remove_filter :retailers
  show do |obj|
    attributes_table do
      row :name
      row :created_at
      row :updated_at
      row :retailers do
        obj.retailers.pluck(:company_name) * (', ')
      end
    end
  end
end