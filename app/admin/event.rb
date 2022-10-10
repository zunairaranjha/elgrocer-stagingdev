# frozen_string_literal: true

ActiveAdmin.register Event do
  menu parent: "Collections"
  
  permit_params :name, :description

  actions :all, except: [:destroy]

  index do
    column :name
    column :description
    actions
  end

  filter :name

  form do |f|
    f.inputs 'Basic event details' do
      f.input :name
      f.input :description, as: :text
    end
    f.actions
  end
end
