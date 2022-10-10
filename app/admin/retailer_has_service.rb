# frozen_string_literal: true

ActiveAdmin.register RetailerHasService do
  menu parent: "Retailers"
  permit_params :retailer_id, :retailer_service_id, :service_fee, :min_basket_value, :delivery_slot_skip_time, :cutoff_time, :is_active, :created_at, :delivery_type
  includes :retailer, :retailer_service
  actions :all, except: [:delete]

  filter :retailer_id, label: "RETAILER ID"
  filter :retailer_service_id, label: "RETAILER HAS SERVICES ID"
  filter :created_at

  index do
    column :retailer
    column :retailer_service
    column :delivery_type
    column :cutoff_time
    column :is_active
    column :created_at
    actions
  end
  form do |f|
    f.inputs "Retailer Has Services" do
      f.input :retailer_service_id, as: :select, collection: controller.retailer_services
      f.input :retailer_id, as: :select, collection: controller.active_retailers
      f.input :min_basket_value
      f.input :service_fee
      f.input :delivery_type, as: :select
      f.input :delivery_slot_skip_time, hint: 'delivery slots after 4:00 hours'
      f.input :cutoff_time, :as => :string, input_html: {value: f.object.order_cutoff_time.try(:strip)}, hint: 'after 20:00 no order for tomorrow delivery slots order will be on day after tomorrow delivery slots'
      f.input :is_active
    end
    f.actions
  end

  controller do
    def active_retailers
      @active_retailers ||= Retailer.where(is_active: true).select(:id, :company_name)
    end

    def retailer_services
      @retailer_services ||= RetailerService.select(:id, :name)
    end
  end
  
end
