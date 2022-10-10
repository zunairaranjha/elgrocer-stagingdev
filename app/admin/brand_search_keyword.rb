# frozen_string_literal: true

ActiveAdmin.register BrandSearchKeyword do
  menu parent: 'Brands'

  permit_params :keywords, :product_ids, :start_date, :end_date

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end
  index do
    column :id
    column :keywords
    column :product_ids
    column :start_date
    column :end_date
    actions
  end

  form do |f|
    f.inputs 'Basic Details' do
      f.input :keywords
      f.input :product_ids
      f.input :start_date, as: :datepicker
      f.input :end_date, as: :datepicker
    end
    f.actions
  end

end
