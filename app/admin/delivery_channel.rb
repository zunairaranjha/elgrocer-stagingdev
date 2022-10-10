# frozen_string_literal: true

ActiveAdmin.register DeliveryChannel do
  menu parent: "Orders"
  permit_params :name

  remove_filter :orders

  form html: {enctype: "multipart/form-data"} do |f|
    f.inputs "Delivery Channel" do
      f.input :name
    end
    f.actions
  end

end
