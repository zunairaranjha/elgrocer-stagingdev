# frozen_string_literal: true

ActiveAdmin.register PromotionCodeRealization do
  menu parent: 'Promotion Codes', label: 'Realizations'

  actions :all, except: [:new, :edit, :destroy]

  permit_params :retailer_id, :promotion_code_id, :order_id, :realization_date

  filter :promotion_code_code, as: :string
  filter :retailer_id
  filter :order_id
  filter :realization_date
  filter :promotion_code_reference, as: :string
  filter :promotion_code_promotion_type, as: :string
  remove_filter :retailer

  scope :successful, default: true
  controller do
    def scoped_collection
      super.includes :order, :retailer, :promotion_code
    end
  end

  index do |realizations|
    column :promotion_code
    column 'Code' do |realization|
      realization.promotion_code.code
    end
    column 'Type' do |realization|
      realization.promotion_code.promotion_type
    end
    column 'Value' do |realization|
      "#{(realization.promotion_code.value_cents/100).round(2)} AED"
    end
    column :retailer
    column :order
    column :realization_date
    column 'Reference' do |realization|
      realization.promotion_code.reference
    end
    actions

    panel 'Filtered realizations summary' do
      realizations = PromotionCodeRealization.joins(:promotion_code).search(params[:q]).result.successful
      total = realizations.sum("promotion_codes.value_cents")
      #total = 0
      #realizations.each do |realization|
      #  total += realization.promotion_code.value_cents
      #end
      ul do
        li h4 "Total value of realizations: #{(total/100).round(2)} AED"
        li h4 "Total number of realizations: #{realizations.count}"
      end
    end
  end

  # filter :promotion_code_code, as: :string
  # filter :retailer
  # filter :order_id
  # filter :realization_date

  csv do
    column :id
    column :promotion_code_id
    column(:promotion_code_name) { |pcr| pcr.promotion_code.code }
    column(:promotion_code_value) { |pcr| pcr.promotion_code.value }
    column :shopper_id
    column :order_id
    column :realization_date
    column :retailer_id
    column(:retailer_name) { |pcr| pcr.retailer.try(:name) }
  end
end
