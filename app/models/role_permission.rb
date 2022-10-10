class RolePermission < ApplicationRecord
    belongs_to :role
    # belongs_to :permission
    belongs_to :permission_domain, optional: true, :class_name => "Permission", :foreign_key => "permission_id"
    has_many :subpermissions, through: :permission_domain
end
