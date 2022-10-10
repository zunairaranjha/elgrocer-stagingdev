# frozen_string_literal: true

ActiveAdmin.register_page "Retailer Priority" do
  menu parent: "Retailers"

  content do
    render partial: "form", locals: {retailers: Retailer.order(:priority)}
  end

  page_action :update_retailer_priority, method: :post do
      params[:retailers].each_pair do |retailer_id, position|
        Retailer.find(retailer_id).update_column(:priority, position.to_i)
      end
      redirect_to admin_retailer_priority_path, notice: "Retailer updated"
  end
end
