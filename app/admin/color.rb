# frozen_string_literal: true

ActiveAdmin.register Color do
  menu parent: "Settings"
  permit_params :name, :name_ar, :color_code

  form do |f|
    f.inputs 'Color' do
      f.input :name
      f.input :name_ar
      f.input :color_code, as: :string, hint: 'cc0033'
    end
    f.actions
  end
end
