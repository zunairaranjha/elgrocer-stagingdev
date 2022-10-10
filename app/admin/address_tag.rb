# frozen_string_literal: true

ActiveAdmin.register AddressTag do
  menu parent: "Shoppers"
  actions :all, except: [:destroy]
  permit_params :id, :name, :name_ar, :priority

  remove_filter :shopper_addresses
  # actions :index, :show

end

