# frozen_string_literal: true

ActiveAdmin.register EmployeeActivity do
  menu parent: "Employee"
  includes :event, :order, employee: [:retailer]
  actions :all, except: [:new, :edit, :destroy]

  filter :order_id
  filter :employee_id, label: 'Employee ID'
  filter :employee_name_cont, as: :string, label: "Employee Name"
  filter :retailer_id_eq, label: 'Retailer ID'
  filter :retailer_company_name_cont, as: :string, label: "Retailer Name"
  filter :created_at

  index do
    column :employee
    column "Retailer" do |emp|
      emp.employee.retailer
    end
    column :event
    column :order
    column :created_at
    # actions
  end

  csv do
    column "Employee Id" do |oa|
      oa.employee_id
    end
    column :employee_name do |oa|
      oa.employee.name
    end
    column "Employee Roles" do |oa|
      oa.employee.employee_roles.pluck(:name).join(',')
    end
    column "Retailer Id" do |oa|
      oa.employee.retailer_id
    end
    column "Retailer Name" do |oa|
      oa.employee.retailer.company_name
    end
    column :event do |oa|
      oa.event.name
    end
    column :order_id
    column :created_at
  end


end
