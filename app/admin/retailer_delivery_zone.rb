# frozen_string_literal: true

ActiveAdmin.register RetailerDeliveryZone do
  menu false
  permit_params :delivery_zone_id, :retailer_id, :min_basket_value, :delivery_fee, :rider_fee, :cutoff_time, :delivery_type, :delivery_slot_skip_time,
                retailer_opening_hours_attributes: %i[id retailer_id day open close retailer_delivery_zone_id _destroy],
                delivery_slots_attributes: %i[id day start end retailer_delivery_zone_id orders_limit _destroy products_limit products_limit_margin is_active retailer_id retailer_service_id]

  controller do
    def scoped_collection
      super.includes :retailer, :delivery_zone
    end
  end

  index do
    column(I18n.t('company_name', scope: 'activerecord.labels.retailer')) { |c| c.retailer&.company_name.to_s }
    column(I18n.t('name', scope: 'activerecord.labels.locations')) { |c| c.delivery_zone&.name }
    column(I18n.t('min_basket_value', scope: 'activerecord.labels.locations'), &:min_basket_value)
    column :order_cutoff_time
    column :delivery_slot_skip_hours
    column :delivery_type
    actions
  end

  filter :retailer_company_name_cont, as: :string
  filter :delivery_zone_name_cont, as: :string

  show do
    attributes_table do
      row :retailer
      row :delivery_zone
      row :min_basket_value
      row :delivery_fee
      row :rider_fee
      row :delivery_slot_skip_hours
      row :order_cutoff_time
      row :delivery_type
      row :created_at
      row :updated_at
      panel 'Scheduled close timings' do
        attributes_table_for retailer_delivery_zone.retailer_opening_hours do
          rows :day_name, :close_time, :open_time
        end
      end
      # panel "Scheduled delivery slots" do
      #   attributes_table_for retailer_delivery_zone.delivery_slots do
      #     rows :day_name, :start_time, :end_time, :products_limit, :products_limit_margin #, :orders_limit
      #   end
      # end
      panel 'Scheduled delivery slots' do
        table_for retailer_delivery_zone.delivery_slots.includes(:retailer_service).order(:day, :start) do
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
  end

  form do |f|
    f.inputs 'Create Delivery Zone' do
      f.input :retailer
      f.input :delivery_zone
      f.input :min_basket_value
      f.input :delivery_fee
      f.input :rider_fee
      f.input :delivery_slot_skip_time, :as => :string, input_html: { value: f.object.delivery_slot_skip_hours.try(:strip) }, hint: 'delivery slots after 4:00 hours'
      f.input :cutoff_time, :as => :string, input_html: { value: f.object.order_cutoff_time.try(:strip) }, hint: 'after 20:00 no order for tomorrow delivery slots order will be on day after tomorrow delivery slots'
      f.input :delivery_type, as: :select
      f.has_many :retailer_opening_hours, heading: 'Schedule Close Timings', new_record: 'Add New', name: false, allow_destroy: true do |cf|
        cf.object.retailer_id = 0
        cf.object[:close] = TimeOfDayAttr.l(cf.object[:close]) unless cf.object[:close].blank?
        cf.object[:open] = TimeOfDayAttr.l(cf.object[:open]) unless cf.object[:open].blank?
        cf.input :retailer_id, as: :hidden
        cf.input :day, as: :select, collection: RetailerOpeningHour.days
        cf.input :close, :as => :string
        cf.input :open, :as => :string
      end
      f.has_many :delivery_slots, heading: 'Schedule Delivery Slots', new_record: 'Add New', name: false, allow_destroy: true do |cf|
        cf.input :day, as: :select, collection: DeliverySlot.days
        cf.input :start, :as => :string, input_html: { value: cf.object.start_time }
        cf.input :end, :as => :string, input_html: { value: cf.object.end_time }
        cf.input :orders_limit
        cf.input :products_limit
        cf.input :products_limit_margin
        cf.input :is_active
        # cf.input :retailer_service_id
      end
    end
    f.actions
  end

  controller do
    def new
      retailer = Retailer.find_by(id: params[:retailer_id])
      super do |format|
        @retailer_delivery_zone.retailer = retailer
      end
    end

    def delivery_zone_id
      params[:retailer_delivery_zone][:delivery_zone_id]
    end

    def retailer_id
      params[:retailer_delivery_zone][:retailer_id]
    end

    def get_retailer_delivery_zone
      RetailerDeliveryZone.find_by(delivery_zone_id: delivery_zone_id, retailer_id: retailer_id)
    end

    def check_if_a_model_exists
      get_retailer_delivery_zone.present?
    end

    def create
      unless check_if_a_model_exists
        retailer_id = params[:retailer_delivery_zone][:retailer_id]
        set_param(retailer_id) if params[:retailer_delivery_zone][:delivery_slots_attributes].present?
        create! do
          redirect_to admin_retailer_delivery_zones_path(q: { retailer_id_eq: retailer_id }) and return
        end
      else
        redirect_to admin_retailer_delivery_zones_path(q: { retailer_id_eq: retailer_id }),
                    notice: 'The retailer already has this location!' and return
      end
    end

    def update
      set_param(params[:retailer_delivery_zone][:retailer_id]) if params[:retailer_delivery_zone][:delivery_slots_attributes].present?
      super
    end

    def set_param(retailer_id)
      params[:retailer_delivery_zone][:delivery_slots_attributes].transform_values do |ds|
        ds[:retailer_id] = retailer_id
        ds[:retailer_service_id] = '1'
      end
    end
  end
end
