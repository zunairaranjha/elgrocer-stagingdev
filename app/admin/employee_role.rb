# frozen_string_literal: true

ActiveAdmin.register EmployeeRole do
  menu parent: "Employee"
  permit_params :name
  actions :all, except: [:edit, :destroy]

end
