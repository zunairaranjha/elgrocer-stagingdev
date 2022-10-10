# frozen_string_literal: true

ActiveAdmin.register RetailerHasAvailablePaymentType do
  menu parent: "Retailers"
  permit_params :id, :retailer_id, :available_payment_type_id, :retailer_service_id, :accept_promocode,:created_at, :updated_at
  includes :retailer, :available_payment_type
  actions :all , except: [:new, :destroy]
  form do |f|
    f.inputs "Retailer Has Available Payment Type" do
      f.input :retailer
      f.input :available_payment_type
      f.input :retailer_service_id, as: :select, collection: controller.retailer_services.select(:id, :name)
      f.input :accept_promocode
    end
    f.actions
  end

  batch_action :enable_accept_promocodes do |ids|
    RetailerHasAvailablePaymentType.where(id: ids).update_all(accept_promocode: true, updated_at: Time.now)
    redirect_to admin_retailer_has_available_payment_types_path, alert: "Promocodes have been Activated."
  end

  
  batch_action :disable_accept_promocodes do |ids|
    RetailerHasAvailablePaymentType.where(id: ids).update_all(accept_promocode: false, updated_at: Time.now)
    redirect_to admin_retailer_has_available_payment_types_path, alert: "Promocodes have been Deactivated."
  end

  controller do

    def retailer_services
      @retailer_services ||= RetailerService.select(:id, :name)
    end
  end
end
