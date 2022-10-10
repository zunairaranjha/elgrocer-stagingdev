# frozen_string_literal: true

ActiveAdmin.register SystemConfiguration do
  menu parent: "Settings"
  actions :all, except: [:destroy]
  permit_params :id, :key, :value, :created_at, :updated_at

end

