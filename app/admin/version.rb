# frozen_string_literal: true

ActiveAdmin.register Version do
  menu parent: "Settings"
  permit_params :majorversion, :minorversion, :revision, :devise_type, :action, :message

  index do
    column :majorversion
    column :minorversion
    column :revision
    column :devise_type
    column :action
    actions
  end

  filter :devise_type
  filter :action

  form do |f|
    f.inputs 'Basic version details' do
      f.input :majorversion
      f.input :minorversion
      f.input :revision
      f.input :devise_type, hint: '0 - Android Retailer App; 1 - iOS Shopper App; 2 - Android Shopper App'
      f.input :action, hint: '0 - Update not necessary; 1 - Update necessary'
      f.input :message
    end
    f.actions
  end
end
