# frozen_string_literal: true

ActiveAdmin.register CarouselProduct do
  menu parent: 'Brands'

  permit_params :product_ids, :start_date, :end_date

  index do
    column :id
    column :product_ids
    column :start_date
    column :end_date
    actions
  end

  form do |f|
    f.inputs 'Basic Details' do
      f.input :product_ids, hint: 'Comma separated Product ids e.g. 3378,2351,5514,2278'
      f.input :start_date, as: :datepicker
      f.input :end_date, as: :datepicker
    end
    f.actions
  end

end
