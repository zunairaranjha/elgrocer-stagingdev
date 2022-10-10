# frozen_string_literal: true

ActiveAdmin.register Retailer, as: 'click_and_collect_slot' do
  menu false
  permit_params :id, cc_slots_attributes: %i[id day start end retailer_delivery_zone_id orders_limit products_limit products_limit_margin is_active retailer_service_id]
  actions :all, except: %i[new view destroy]

  config.filters = false
  config.per_page = 0

  action_item :batch_slots, only: :show do
    link_to 'New Click and Collect Slot', new_admin_slots_batch_action_path
  end

  form do |f|
    f.inputs 'Delivery Slot Details' do
      f.has_many :cc_slots, heading: 'Click and Collect Delivery Slots', new_record: 'Add New', name: false, allow_destroy: true do |cf|
        cf.input :day, as: :select, collection: DeliverySlot.days
        cf.input :start, as: :string, input_html: { value: cf.object.start_time }
        cf.input :end, as: :string, input_html: { value: cf.object.end_time }
        cf.input :orders_limit
        cf.input :products_limit
        cf.input :products_limit_margin
        cf.input :is_active
      end
    end
    f.actions do
      if resource.persisted?
        f.action :submit, label: 'Update Click and Collect Slots'
      else
        f.action :submit, label: 'Create Click and Collect Slots'
      end
      f.cancel_link(admin_click_and_collect_slot_path(id: params[:id]))
    end
  end

  show do |retailer|
    panel 'Click and Collect delivery slots' do
      table_for retailer.cc_slots.includes(:retailer_service) do
        column :id
        column :day_name
        column :start_time
        column :end_time
        column :orders_limit
        column :products_limit
        column :products_limit_margin
        column :is_active
        column :retailer_service
      end
    end
  end

  index pagination_total: false do

  end

  controller do
    def create

    end

    def update
      super
    end
  end
end

