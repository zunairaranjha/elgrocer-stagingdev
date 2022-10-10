class EmployeeActivity < ActiveRecord::Base
  belongs_to :employee, optional: true
  belongs_to :order, optional: true
  has_one :retailer, through: :order
  belongs_to :event, optional: true

  def self.add_activity(name, employee_id, order_id = nil)
    begin
      event = Event.find_or_create_by(:name => name)
      EmployeeActivity.create(:employee_id => employee_id, :event_id => event.id, order_id: order_id) if event.present?
    rescue => e
    end
  end
end
