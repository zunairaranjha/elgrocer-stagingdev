class OrderAllocation < ActiveRecord::Base
  belongs_to :order, optional: true, touch: true
  has_one :retailer, through: :order
  belongs_to :employee, optional: true
  belongs_to :event, optional: true
  belongs_to :owner, optional: true, polymorphic: true

  scope :active, -> { where(is_active: true) }
  scope :for_order, ->(id) { where(order_id: id) }
  scope :for_employee, ->(id) { where(employee_id: id) }
  scope :for_order_employee, ->(order_id, employee_id) { where( employee_id: employee_id, order_id: order_id) }

  def self.create_allocation(name, employee_id, order_id, owner)
    begin
      event = Event.find_or_create_by(name: name)
      OrderAllocation.create(employee_id: employee_id, event_id: event.id, order_id: order_id, owner: owner) if event.present?
    rescue => e
    end
  end

end
