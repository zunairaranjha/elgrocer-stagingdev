ActiveAdmin.register Permission do
  menu parent: "Access Rights"
    # actions :index
    includes :parent
    
  permit_params :name,:parent_id, :created_at, :updated_at
  index do
    column :id
    column :name
    column 'Domain' do |c|
      c.parent
    end
    column :created_at
    column :updated_at
    actions
  end

  filter :name
  filter :parent, label: 'Domain', as: :select, collection: proc { controller.permission }
  form do |f|
    f.inputs "Basic details" do
      perm_id = params[:id].present? ? params[:id] : 0
      f.input :name
      f.input :parent, label: 'Domain', as: :select, collection: Permission.order(:name).where("parent_id is null and id != #{perm_id}").pluck(:name, :id) unless f.object.subpermissions.count > 0
    end
    f.actions
  end

  show do |brand|
    attributes_table :name do
      row 'Domain' do |c|
        c.parent
      end
    end

  end

  csv do
    column :id
    column :name
    column 'Domain' do |c|
      c.parent.try(:name)
    end
    column :created_at
    column :updated_at
  end

  
  controller do

    def destroy
      if resource.role_permissions.count > 0
        redirect_to admin_permissions_path, flash: {notice: "Removal impossible. There is a Role having this dimension."}
      else
        super
      end

    end

    def permission
      Permission.order(:name).where(parent_id: nil).pluck(:name, :id)
    end
  end

end
  