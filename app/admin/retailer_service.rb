# frozen_string_literal: true

ActiveAdmin.register RetailerService do
  menu parent: 'Retailers'
  permit_params :name, :availability_radius, :search_radius, :created_at, :updated_at,
                retailer_has_services_attributes: [:id, :retailer_id, :retailer_service_id, :service_fee, :delivery_slot_skip_time, :cutoff_time, :min_basket_value, :is_active]

  actions :all, except: [:destroy]

  filter :name
  filter :created_at
  filter :updated_at

  index do |obj|
    column :id
    column :name
    column :search_radius
    column :availability_radius
    column :created_at
    column :updated_at
    actions
  end

  show do |obj|
    panel "Service Detail" do
      attributes_table_for obj do
        row :name
        row :availability_radius
        row :search_radius
        row :created_at
        row :updated_at
      end
    end
    panel "Retailer Has Service Detail" do
      table_for obj.retailer_has_services.includes(:retailer) do
        column :retailer
        column :min_basket_value
        column :service_fee
        column :delivery_slot_skip_time
        column :order_cutoff_time
        column :is_active
      end
    end

  end

  form do |f|
    f.inputs "Retailer Service" do
      f.input :name
      f.input :availability_radius
      f.input :search_radius
      # f.has_many :retailer_has_services, heading: "Add Retailer", new_record: "Add New", name: false do |cf|
      #   cf.input :retailer_id, as: :select, collection: controller.active_retailers
      #   cf.input :min_basket_value
      #   cf.input :service_fee
      #   cf.input :delivery_slot_skip_time, hint: 'delivery slots after 4:00 hours'
      #   cf.input :cutoff_time, :as => :string, input_html: {value: cf.object.order_cutoff_time.try(:strip)}, hint: 'after 20:00 no order for tomorrow delivery slots order will be on day after tomorrow delivery slots'
      #   cf.input :is_active
      # end
    end
    f.actions
  end

  controller do
    def active_retailers
      @active_retailers ||= Retailer.where(is_active: true).select(:id, :company_name)
    end
  end
end
