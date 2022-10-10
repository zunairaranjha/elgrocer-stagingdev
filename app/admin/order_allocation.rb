# frozen_string_literal: true

ActiveAdmin.register OrderAllocation do
  menu parent: "Employee"
  includes :event, :order, :owner, employee: [:retailer]
  actions :all, except: [:new, :edit, :destroy]

  filter :order_id, label: 'Order ID'
  filter :employee_id, label: 'Employee ID'
  filter :employee_name_cont, as: :string, label: 'Employee Name'
  filter :retailer_id_eq, label: 'Retailer ID'
  filter :retailer_company_name_cont, as: :string, label: 'Retailer Name'
  filter :owner_id, label: 'Owner ID'
  filter :event
  filter :is_active
  filter :created_at

  index do
    column :order
    column :employee
    column "Retailer" do |emp_ac|
      emp_ac.employee.retailer
    end
    column :event
    column :is_active
    column :created_at
    column :owner
    column :owner_type
    # actions
  end

  csv do
    column :order_id
    column "Employee Id" do |oa|
      oa.employee_id
    end
    column :employee_name do |oa|
      oa.employee.name
    end
    column "Retailer Id" do |oa|
      oa.employee.retailer_id
    end
    column "Retailer Name" do |oa|
      oa.employee.retailer&.company_name
    end
    column :event do |oa|
      oa.event.name
    end
    column :is_active
    column :created_at
    column "Owner Id" do |oa|
      oa.owner_id
    end
    column :owner_name do |oa|
      oa.owner.name
    end
    column :owner_type
  end

end
