ActiveAdmin.register Role do
  menu parent: "Access Rights"
    # includes :role_permissions, :admin_users
    permit_params :name,:retailer_group_ids, :city_ids, :retailer_group, :cities, :can_create, :can_update, :can_delete, :admin_user_access, :can_read

    member_action :clone_role, method: :get do
      @resource = resource.dup
      @resource.name = "Clone-#{resource.name}"
      @resource.can_read   = resource.role_permissions.where(can_read: "read").pluck(:permission_id)
      @resource.can_update = resource.role_permissions.where(can_update: "update").pluck(:permission_id)
      @resource.can_create = resource.role_permissions.where(can_create: "create").pluck(:permission_id)
      @resource.can_delete = resource.role_permissions.where(can_delete: "destroy").pluck(:permission_id)
      render :new, :layout => false
    end

    form do |f|
      f.object.retailer_group = resource.retailer_group_ids
      f.object.cities = resource.city_ids
      f.object.can_read =   resource.role_permissions.where(can_read: "read").pluck(:permission_id)    if resource.id != nil
      f.object.can_update = resource.role_permissions.where(can_update: "update").pluck(:permission_id)   if resource.id != nil
      f.object.can_create = resource.role_permissions.where(can_create: "create").pluck(:permission_id)  if resource.id != nil
      f.object.can_delete = resource.role_permissions.where(can_delete: "destroy").pluck(:permission_id)  if resource.id != nil
      
      f.object.admin_user_access = AdminUser.where(role_id: resource.id).pluck(:id) if resource.id != nil
      f.inputs 'Role Details' do
        f.input :name
        f.input :retailer_group, as: :select, multiple: true, collection: RetailerGroup.pluck(:name, :id)
        f.input :cities , as: :select, multiple: true, collection: City.pluck(:name, :id)
        f.input :admin_user_access, as: :select, multiple: true, collection: AdminUser.pluck(:email, :id)
        f.input :can_read, as: :select, multiple: true,   collection: controller.permission, :hint => "Give Read Access Here"
        f.input :can_update, as: :select, multiple: true, collection: controller.permission, :hint => "Give Update Access Here"
        f.input :can_create, as: :select, multiple: true, collection: controller.permission, :hint => "Give Create Access Here"
        f.input :can_delete, as: :select, multiple: true, collection: controller.permission, :hint => "Give Delete Access Here"
        
      end
      f.actions
    end
  
    show do
      attributes_table do
        row :name
        row :retailer_group_ids
        row :city_ids
        row :created_at
        row :updated_at
        row "Admin Users" do |c|
          c.admin_users.pluck(:email)
        end
        panel "Role Permissionss" do
          table_for role.role_permissions.includes(:permission_domain) do # Role.includes(:admin_users, :role_permissions, :permissions).where(id: role.id)
            column :permission_domain
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
          end
        end
      end
    end

    index do
      column :id
      column :name
      column :retailer_group_ids
      column :city_ids
      column :created_at
      column :updated_at
      actions :only => :show do  |rol|
        link_to("Clone", "/admin/roles/#{rol.id}/clone_role")
      end
      # actions
    end

    filter :name 
    
    csv do
      column :name
      column :retailer_group_ids
      column :city_ids
      column 'Admin Users' do |c|
        c.admin_users.pluck(:email)
      end
      column :created_at
      column :updated_at
    end

    controller do

      def create
        set_params
        super
        role_permission_update
       

      end
      def update
        set_params
        super
        RolePermission.where(role_id: @role.id).delete_all
        AdminUser.where(role_id: @role.id).update_all(role_id: nil)
        role_permission_update


      end
        
      def destroy
        RolePermission.where(role_id: params[:id]).delete_all
        AdminUser.where(role_id: params[:id]).update_all(role_id: nil)
        super
      end

      def set_params
          params[:role][:retailer_group_ids] = "{#{params[:role][:retailer_group].reject(&:blank?).map(&:to_i).join(',')}}"   
          params[:role][:city_ids] = "{#{params[:role][:cities].reject(&:blank?).map(&:to_i).join(',')}}"
      end

      def permission
        Permission.where(parent_id: nil).pluck(:name, :id)
      end

      def role_permission_update
        can_read = params[:role][:can_read].reject(&:blank?) 
        can_update = params[:role][:can_update].reject(&:blank?)
        can_create = params[:role][:can_create].reject(&:blank?)
        can_delete = params[:role][:can_delete].reject(&:blank?)
        admin_users_access = params[:role][:admin_user_access].reject(&:blank?) 
        unless can_read.blank?
          can_read.each do |perm_id|
            RolePermission.create(role_id:@role.id, permission_id: perm_id, can_read: "read")
          end
        end

        
        unless can_update.blank?
          can_update.each do |perm_id|
            role = RolePermission.find_or_initialize_by(role_id: @role.id, permission_id: perm_id)
            role.update(can_update: "update", can_read: "read")
            # role = RolePermission.find_by(role_id:@role.id, permission_id: perm_id)
            # role.update_column(:can_update, "update") if role  
          end
        end

        
        unless can_create.blank?
          can_create.each do |perm_id|
            role = RolePermission.find_or_initialize_by(role_id: @role.id, permission_id: perm_id)
            role.update(can_create: "create", can_read: "read")
            # role = RolePermission.find_by(role_id:@role.id, permission_id: perm_id)
            # role.update_column(:can_create, "create") if role
          end
        end

        
        unless can_delete.blank?
          can_delete.each do |perm_id|
            role = RolePermission.find_or_initialize_by(role_id: @role.id, permission_id: perm_id)
            role.update(can_delete: "destroy", can_read: "read")
          #  role =  RolePermission.find_by(role_id:@role.id, permission_id: perm_id)
          #  role.update_column(:can_delete, "destroy") if role 
          end
        end

         
        unless admin_users_access.blank?
          admin_users_access.each do |admin_id|
            AdminUser.find_by(id: admin_id).update_column(:role_id, @role.id)
          end
        end

      end

    end
end