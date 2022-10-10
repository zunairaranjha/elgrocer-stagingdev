# frozen_string_literal: true

ActiveAdmin.register PaymentThreshold do
  menu parent: "Employee"
  includes :employee, :order
  actions :all, except: [:new,:edit,:destroy]

  remove_filter :order
  remove_filter :employee

end
