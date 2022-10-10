# frozen_string_literal: true

ActiveAdmin.register AvailablePaymentType do
  menu parent: 'Collections'
  permit_params :name

  index do
    column :name
    column :created_at
    actions
  end

  filter :name

  show do |brand|
    attributes_table :name, :created_at do
    end
  end

  form html: { enctype: 'multipart/form-data' } do |f|
    f.inputs 'Basic details' do
      f.input :name
    end
    f.actions
  end
end