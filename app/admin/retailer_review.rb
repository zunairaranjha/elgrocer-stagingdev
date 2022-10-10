# frozen_string_literal: true

ActiveAdmin.register RetailerReview, as: 'Review' do
  permit_params :retailer_id, :delivery_speed_rating, :overall_rating,
                :order_accuracy_rating, :quality_rating,
                :price_rating, :comment, :shopper_id

  menu parent: 'Retailers'

  remove_filter :retailer
  remove_filter :shopper

  controller do
    def scoped_collection
      super.includes :shopper, :retailer
    end
  end

  index do
    column('Shopper name') { |c| link_to(c.shopper_name, admin_shopper_path(c.shopper_id)) rescue c.shopper_name }
    column('Retailer Name') { |c| link_to(c.retailer_company_name, admin_retailer_path(c.retailer_id)) rescue c.retailer_company_name }
    column :overall_rating
    column :created_at
    actions
  end

  filter :retailer
  filter :shopper
  filter :overall_rating
  filter :created_at
end
