# frozen_string_literal: true

ActiveAdmin.register VehicleModel do
  menu parent: "Settings"
  permit_params :id, :name

end

