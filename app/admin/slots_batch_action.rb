# frozen_string_literal: true

ActiveAdmin.register DeliverySlot, as: "slots_batch_action" do
  menu false
  permit_params :id,:start,:end,:day,:retailer_delivery_zone_id, :products_limit, :products_limit_margin,:orders_limit, :slot_interval, :is_active, :retailer_service_id, :retailer_id

  controller do
    def scoped_collection
      super.includes retailer_delivery_zone: [:retailer, :delivery_zone]
    end
  end

  actions :all, except: [:edit,:view,:destroy]

  filter :retailer_delivery_zone_id
  filter :day, as: :select, collection: DeliverySlot.days
  filter :start
  filter :end
  filter :orders_limit
  filter :products_limit
  filter :products_limit_margin
  filter :is_active

  form do |f|
    f.inputs 'Delivery Slot Details' do
      f.input :retailer_service_id, as: :select, collection: controller.retailer_services.select(:id, :name)
      f.input :retailer_delivery_zone_id, as: :nested_select,
              level_1: { attribute: :retailer_id,
                         collection: controller.retailers},
              level_2: { attribute: :retailer_delivery_zone_id,
                         collection: controller.retailer_delivery_zones}
      f.input :day, as: :check_boxes, collection: DeliverySlot.days
      f.input :start, lable: "Starting Time", :as => :string, input_html: {value: object.start_time}
      f.input :end, lable: "Ending Time", :as => :string, input_html: {value: object.end_time}
      f.input :slot_interval,:as => :number, hint: "Interval in minutes e.g. '60'"
      f.input :orders_limit
      f.input :products_limit
      f.input :products_limit_margin
      f.inputs :is_active
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
      row :retailer_id
    end
  end

  controller do
    def create
      days = params[:delivery_slot][:day].reject(&:blank?)
      starting_time = params[:delivery_slot][:start]
      starting_time = starting_time.split(':')[0].to_i * 3600 + starting_time.split(':')[1].to_i * 60
      ending_time = params[:delivery_slot][:end]
      ending_time = ending_time.split(':')[0].to_i * 3600 + ending_time.split(':')[1].to_i * 60
      slot_interval = params[:delivery_slot][:slot_interval]
      orders_limit = params[:delivery_slot][:orders_limit]
      products_limit = params[:delivery_slot][:products_limit]
      products_margin = params[:delivery_slot][:products_limit_margin]
      retailer_delivery_zone_id = params[:delivery_slot][:retailer_delivery_zone_id]
      is_active = params[:delivery_slot][:is_active]
      retailer_service_id = params[:delivery_slot][:retailer_service_id]
      retailer_id = params[:delivery_slot][:retailer_id]
      slots = []
      if days.length > 0 and starting_time < ending_time
        if slot_interval
          while starting_time < ending_time
            slots.push("#{starting_time},#{starting_time + slot_interval.to_i * 60}")
            starting_time += slot_interval.to_i * 60
          end
        end
        days.each do |day|
          slots.each do |se|
            if retailer_service_id.to_i == 1
              slot = DeliverySlot.find_or_initialize_by(day: day, start: se.split(',')[0].to_i, retailer_delivery_zone_id: retailer_delivery_zone_id)
            else
              slot = DeliverySlot.find_or_initialize_by(day: day, start: se.split(',')[0].to_i, retailer_id: retailer_id, retailer_delivery_zone_id: nil, retailer_service_id: retailer_service_id)
            end
            # slot = DeliverySlot.find_or_initialize_by(day: day, start: se.split(',')[0].to_i)  
            slot.start = se.split(',')[0].to_i
            slot.end = se.split(',')[1].to_i
            slot.orders_limit = orders_limit
            slot.products_limit = products_limit
            slot.products_limit_margin = products_margin
            slot.is_active = is_active
            slot.retailer_service_id = retailer_service_id
            slot.retailer_id = retailer_id
            slot.retailer_delivery_zone_id = retailer_delivery_zone_id
            slot.save!
          end
        end
        if retailer_service_id.to_i == 2
          redirect_to admin_click_and_collect_slot_path(id: retailer_id)
        else
          redirect_to admin_retailer_delivery_zone_path(id: retailer_delivery_zone_id), flash: { notice: "Retailer Delivery Zone has been Updated!" }
        end
      else
        super
        # redirect_to admin_retailer_delivery_zone_path(id: retailer_delivery_zone_id), flash: { notice: "Retailer Delivery Zone has been Updated!" }
      end
    end

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

