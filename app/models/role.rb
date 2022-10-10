class Role < ApplicationRecord
    attr_accessor :retailer_group, :cities, :can_read, :can_update, :can_create, :can_delete, :permission, :admin_user_access
    validates :name, presence: true, uniqueness: true
    has_many :admin_users
    has_many :role_permissions
    has_many :permission_domain, through: :role_permissions
    accepts_nested_attributes_for :permission_domain
end
