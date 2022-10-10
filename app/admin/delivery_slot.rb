# frozen_string_literal: true

ActiveAdmin.register DeliverySlot do
  menu parent: "Collections"
  includes :retailer_service, :retailer, retailer_delivery_zone: [:retailer, :delivery_zone]
  permit_params :id, :start, :end, :day, :retailer_delivery_zone_id, :products_limit, :products_limit_margin, :orders_limit, :is_active, :retailer_service_id, :retailer_id

  filter :retailer_delivery_zone_id
  filter :retailer_service_id, as: :select, collection: RetailerService.all
  filter :day, as: :select, collection: DeliverySlot.days
  filter :start
  filter :end
  filter :orders_limit
  filter :products_limit
  filter :products_limit_margin
  filter :is_active


  action_item :batch_slots, only: :index do
    link_to 'Delivery Slots In Batch', new_admin_slots_batch_action_path
  end

  form do |f|
    f.inputs 'Delivery Slot Details' do
      f.input :retailer_service_id, as: :select, collection: controller.retailer_services.select(:id, :name)
      f.input :retailer_delivery_zone_id, as: :nested_select,
              level_1: { attribute: :retailer_id,
                         collection: controller.retailers },
              level_2: { attribute: :retailer_delivery_zone_id,
                         collection: controller.retailer_delivery_zones }
      # f.input :retailer_delivery_zone_id, as: :select, collection: RetailerDeliveryZone.all.includes(:retailer, :delivery_zone).sort_by{|rdz| rdz.name}
      f.input :day, as: :select, collection: DeliverySlot.days
      f.input :start, :as => :string, input_html: { value: object.start_time }
      f.input :end, :as => :string, input_html: { value: object.end_time }
      f.input :orders_limit
      f.input :products_limit
      f.input :products_limit_margin
      f.input :is_active
    end
    f.actions
  end

  index do
    column :id
    column "Day", :day_name
    column "Start", :start_time
    column "End", :end_time
    column :retailer_delivery_zone
    column :orders_limit
    column :products_limit
    column :products_limit_margin
    column :is_active
    column :retailer_service
    column :retailer
    actions
  end

  show do |slot|
    attributes_table do
      row 'Day' do
        slot.day_name
      end
      row 'Start' do
        slot.start_time
      end
      row 'End' do
        slot.end_time
      end
      row :retailer_delivery_zone
      row :orders_limit
      row :products_limit
      row :products_limit_margin
      row :is_active
      row :retailer_service
      row :retailer
    end
  end

  controller do
    def retailer_delivery_zones
      @retailer_delivery_zones ||= RetailerDeliveryZone.joins(:retailer, :delivery_zone).select("retailer_delivery_zones.id, retailer_delivery_zones.retailer_id, format('%s : %s', retailers.company_name, delivery_zones.name) AS rdz_name")
    end

    def retailer_services
      @retailer_services ||= RetailerService.select(:id, :name)
    end

    def retailers
      @retailers ||= Retailer.where(is_active: true).select(:id, :company_name)
    end
  end
end
