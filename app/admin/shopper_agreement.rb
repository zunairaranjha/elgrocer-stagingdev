# frozen_string_literal: true

ActiveAdmin.register ShopperAgreement do
  menu parent: "Shoppers"
  actions :all, except: [:new, :edit, :destroy]
  remove_filter :shopper
  remove_filter :agreement

end
