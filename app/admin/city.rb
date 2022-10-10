# frozen_string_literal: true

ActiveAdmin.register City do
  menu parent: "Collections"
  
  permit_params :name, :is_referral_active, :vat, :slug

  index do
    column :name
    column 'VAT %', :vat
    column :slug
    column :is_referral_active
    actions
  end

  filter :name

  form do |f|
    f.inputs 'Basic city details' do
      f.input :name
      f.input :vat, label: 'VAT %'
      f.input :slug
      f.input :is_referral_active, as: :boolean
    end
    f.actions
  end
end
