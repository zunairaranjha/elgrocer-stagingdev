ActiveAdmin.register RolePermission do
  actions :index
    menu parent: "Access Rights"
    includes :role, :permission_domain
    
    # permit_params :role_id, :permission_id, :can_create, :can_read, :can_update, :can_delete
  index do
    # column :id
    column :role
    column 'Domain' do |c|
      c.permission_domain
    end
    column "can_create" do |c|
      c.can_create.present?
    end
    column "can_read" do |c|
      c.can_read.present?
    end
    column "can_update" do |c|
      c.can_update.present?
    end
    column "can_delete" do |c|
      c.can_delete.present?
    end
    column :created_at
    column :updated_at
    actions
  end

  filter :role
  filter :permission_domain, label: 'Domain', as: :select, collection: proc { controller.permission }

  csv do
    column 'Role Name' do |c|
      c.role.try(:name)
    end
    column 'Domain' do |c|
      c.permission_domain.try(:name)
    end
    column "can_create" do |c|
      c.can_create.present?
    end
    column "can_read" do |c|
      c.can_read.present?
    end
    column "can_update" do |c|
      c.can_update.present?
    end
    column "can_delete" do |c|
      c.can_delete.present?
    end
    column :created_at
    column :updated_at
  end

  controller do
    def permission
      Permission.order(:name).where(parent_id: nil).pluck(:name, :id)
    end
  end
end
  