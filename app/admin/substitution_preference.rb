# frozen_string_literal: true

ActiveAdmin.register SubstitutionPreference do
  menu parent: "Collections"
  actions :all
  
  permit_params :category_id, :brand_priority, :size_priority, :price_priority, :flavour_priority, :min_match, :shopper_id

  remove_filter :category
  remove_filter :shopper
  controller do
    def scoped_collection
      super.includes :category
    end
  end

  index do
    column :category
    column :brand_priority
    column :size_priority
    column :price_priority
    column :flavour_priority
    column :min_match
    column :shopper
    actions
  end

  # filter :name

  # form do |f|
  #   f.inputs 'Basic city details' do
  #     f.input :name
  #     f.input :is_referral_active, as: :boolean
  #   end
  #   f.actions
  # end
end
