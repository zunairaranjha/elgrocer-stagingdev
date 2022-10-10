class Employee < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable, :validatable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable

  validates :user_name, presence: true, uniqueness: {:case_sensitive => false}
  validates :password, presence: true, on: :create
  belongs_to :retailer, optional: true
  has_many :employee_activities
  has_many :order_allocations

  before_save :on_status_change, :on_active

  scope :having_role, ->(role) { where("? = ANY (active_roles)", role) }

  def employee_roles
    EmployeeRole.where(id: self.active_roles)
  end

  def on_status_change
    if self.logged_out?
      self.update_column(:authentication_token, nil)
    else
      ensure_authentication_token
    end
  end

  def on_active
    self.order_allocations.where(order_allocations: {is_active: true}).update_all(is_active: false) unless self.is_active
  end

  def ensure_authentication_token
    self.authentication_token ||= generate_authentication_token
  end

  def remove_auth_and_device
    if registration_id
      # UnregisterNotificationsJob.perform_later(self.registration_id, 0)
      self.update(registration_id: nil, authentication_token: nil)
    else
      self.update(authentication_token: nil)
    end
  end

  enum activity_status: {
      idle: 0,
      logged_out: 1,
      picking: 2,
      checking_out: 3,
      delivering_order: 4
  }

  def login(registration_id, force_login)
    if registration_id
      self.registration_id = registration_id
      # RegisterNotificationsJob.perform_later(self.registration_id, 0)
    end
    login_state = 'Login'
    if force_login
      self.authentication_token = nil
      login_state = 'Force Login'
    end
    self.activity_status = :idle
    save!
    EmployeeActivity.add_activity(login_state, self.id)
    OrderReallocationJob.perform_later(self)
    self
  end

  def logging_out(logout_state)
    if registration_id
      # UnregisterNotificationsJob.perform_later(self.registration_id, 0)
      self.registration_id = nil
    end
    self.activity_status = :logged_out
    save!
    self.order_allocations.where(order_allocations: {is_active: true}).update_all(is_active: false)
    EmployeeActivity.add_activity(logout_state, self.id)
    OrderReallocationJob.perform_later(self)
  end

  def save_push_token!(registration_id)
    if registration_id
      # RegisterNotificationsJob.perform_later(self.registration_id, 0)
      self.registration_id = registration_id
      save!
    end
  end

  def allocate_pending(order_id, owner, status_id)
    if self.employee_roles.pluck(:name).join(',').downcase.include? 'picker'
      employee = Employee.joins(:order_allocations).where(order_allocations: {is_active: true, order_id: order_id}).first
      order_deallocated(employee, order_id) if employee
      OrderAllocation.where(order_id: order_id, is_active: true).update_all(is_active: false)
      OrderAllocation.create_allocation("Order #{Order.statuses.key(status_id).humanize}", self.id, order_id, owner)
      params = {
        'message': I18n.t("push_message.message_103"),
        'order_id': order_id,
        'message_type': 103,
        'retailer_id': self.retailer_id
      }
      push_notification(self.registration_id, params, 0)
      true
    else
      false
    end
  end

  def allocate_ready_for_checkout(order_id, owner, status_id)
    if self.employee_roles.pluck(:name).join(',').downcase.include? 'checkout'
      employee = Employee.joins(:order_allocations).where(order_allocations: {is_active: true, order_id: order_id}).first
      order_deallocated(employee, order_id) if employee
      OrderAllocation.where(order_id: order_id, is_active: true).update_all(is_active: false)
      OrderAllocation.create_allocation("Order #{Order.statuses.key(status_id).humanize}", self.id, order_id, owner)
      params = {
        'message': I18n.t("push_message.message_103"),
        'order_id': order_id,
        'message_type': 103,
        'retailer_id': self.retailer_id
      }
      push_notification(self.registration_id, params, 0)
      true
    else
      false
    end
  end

  def allocate_ready_to_deliver(order_id, owner, status_id)
    if self.employee_roles.pluck(:name).join(',').downcase.include? 'deliver'
      employee = Employee.joins(:order_allocations).where(order_allocations: {is_active: true, order_id: order_id}).first
      order_deallocated(employee, order_id) if employee
      OrderAllocation.where(order_id: order_id, is_active: true).update_all(is_active: false)
      OrderAllocation.create_allocation("Order #{Order.statuses.key(status_id).humanize}", self.id, order_id, owner)
      params = {
        'message': I18n.t("push_message.message_103"),
        'order_id': order_id,
        'message_type': 103,
        'retailer_id': self.retailer_id
      }
      push_notification(self.registration_id, params, 0)
      true
    else
      false
    end
  end

  def new_allocation_notify(order_id = nil )
    params = {
      'message': I18n.t("push_message.message_104"),
      'message_type': 104,
      'retailer_id': self.retailer_id
    }
    params[:order_id] = order_id if order_id
    push_notification(self.registration_id, params, 0)
  end

  def order_deallocated(employee, order_id = nil )
    params = {
        'message': I18n.t("push_message.message_105"),
        'message_type': 105,
        'retailer_id': employee.retailer_id
    }
    params[:order_id] = order_id if order_id
    push_notification(employee.registration_id, params, 0)
  end

  def logout_notification
    params = {
        'message': I18n.t("push_message.message_107"),
        'message_type': 107,
        'retailer_id': self.retailer_id
    }
    push_notification(self.registration_id, params, 0)
  end

  def driver_at_pickup_notify(driver_name: nil)
    params = {
      'message': I18n.t("push_message.message_110"),
      'message_type': 110,
      'retailer_id': self.retailer_id,
      'driver_name': driver_name
    }
    push_notification(self.registration_id, params.compact, 0)
  end

  ransacker :by_active_roles, formatter: proc{ |v|
    Employee.having_role(v).first.try(:id)
  } do |parent|
    parent.table[:id]
  end

  private
  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless Employee.where(authentication_token: token).first
    end
  end

  def push_notification(registration_id, params, device_type)
    PushNotificationJob.perform_later(registration_id, params, device_type, true)
  end
end
