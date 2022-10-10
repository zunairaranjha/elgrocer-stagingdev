class Ability
  include CanCan::Ability

  def initialize(user)
    unless user.class.name == "AdminUser"
      return
    end
    
    unless user.role_id?
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      return
    end

    role = user&.role
    if user.role_id == 1
      can :manage, :all 
    else
      can :read, ActiveAdmin::Page, :name => "Dashboard"
      # permissions = RolePermission.includes(:permission).where(role_id: user.role_id).pluck(:can_read,:can_update,:can_create,:can_delete,:name,:conditions)
      permissions = RolePermission.includes(:subpermissions).where(role_id: user.role_id).pluck("role_permissions.can_read,role_permissions.can_update,role_permissions.can_create,role_permissions.can_delete, permissions.name, permissions.conditions")

      if role.retailer_group_ids? and role.city_ids? 
        retailer_group = role.retailer_group_ids
        city_ids = role.city_ids
      elsif role.retailer_group_ids? and !role.city_ids?
        retailer_group = role.retailer_group_ids
        city_ids = City.pluck(:id)
      elsif !role.retailer_group_ids? and role.city_ids?
        retailer_group = Retailer.distinct.pluck(:retailer_group_id)
        city_ids = role.city_ids
      end

      permissions.each do |perm|
        if (role.retailer_group_ids? == true or role.city_ids? == true) and (perm[5] != '' or perm[5] != nil ) and (mod = perm[4].constantize rescue nil) && mod
          # can perm[0..1].map {|action| action.to_sym}, perm[4].constantize, Hash[perm[5].map {|subject, condition| [subject, eval(condition)] }] 
          can perm[0..1].map {|action| action.to_sym}, perm[4].constantize, eval(perm[5])
          can perm[2..3].map {|action| action.to_sym}, perm[4].constantize  
          can :manage, [Order], eval(perm[5]) if perm[1] == 'update' and perm[4] == "Order" 
          
        elsif (mod = perm[4].constantize rescue nil) && mod
          can perm[0..3].map {|action| action.to_sym}, perm[4].constantize  
          can :manage, [Order] if perm[1] == 'update' and perm[4] == "Order"
          # can :clone, [Role] if perm[2] == "create" and perm[4] == "Role"
        else
            
            can :manage, ActiveAdmin::Page, :name => perm[4]  if perm[1] == "update"  
            can perm[0..3].map {|action| action.to_sym}, ActiveAdmin::Page, :name => perm[4]
        end
        cannot [:update,:create,:destroy], Role
      end
    end

    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
