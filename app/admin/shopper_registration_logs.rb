# frozen_string_literal: true

ActiveAdmin.register ShopperRegistrationLog do
  menu parent: 'Shoppers'


  actions :all, except: [:new,:edit,:destroy]
  # actions :index, :show

  filter :shopper_id, label: 'shopper_id'
  filter :partner_name
  filter :success
  filter :created_at

  index do
    column :id
    column :shopper_id
    column :partner_name
    column :success
    column :created_at
    actions
  end

  # show do
  #
  # end
end
