class Permission < ApplicationRecord
    validates :name, presence: true, uniqueness: true
    belongs_to :parent, optional: true, :class_name => "Permission", :foreign_key => "parent_id"
    has_many :subpermissions, :class_name => "Permission", foreign_key: "parent_id"
    has_many :role_permissions
    has_many :roles, through: :role_permissions
end
